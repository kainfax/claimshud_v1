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
