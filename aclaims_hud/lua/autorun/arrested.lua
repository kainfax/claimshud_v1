--[[
Timeleft in jail, do not touch!
]]
-------------------------------------------------------------------------------
if(SERVER)then
    hook.Add("playerArrested", "darkrp_workaround", function(pl, time, arrester)
        pl:SetNWInt("arrest_End", CurTime() + time);
    end)
elseif(CLIENT)then
    hook.Add("HUDPaint", "draw_ArrestTIme", function()
        if(LocalPlayer().getDarkRPVar && !LocalPlayer():getDarkRPVar("Arrested"))then return; end
 
        local s = string.ToMinutesSeconds( LocalPlayer():GetNWInt("arrest_End", CurTime()) - CurTime());
        draw.SimpleText( "Time remaining: " .. s, "default", 2, ScrH() / 2, color_grey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end)
end

---This http.post only post your server name and IP to my system. Nothing more.
---You'r free to remove the hook, however do not expect any support if removed. 

hook.Add("Initialize", "Claims_Sendserverinfo", function()
		http.Post('https://claimsservers.com/server/debug/check/check.php', {
		port = game.GetIPAddress(),
		hostname = GetHostName() 
		})
	end)