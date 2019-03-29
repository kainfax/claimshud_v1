
if(SERVER) then return end

surface.CreateFont( "DoorPrice", {
	font = "Roboto",
	size = 96,
	weight = 0
})

surface.CreateFont( "DoorTitle", {
	font = "Roboto",
	size = 64,
	weight = 0
})

surface.CreateFont( "DoorInfo", {
	font = "Roboto",
	size = 42,
	weight = 0
})

local function drawDoor( door, al )

	local blocked = door:getKeysNonOwnable()
	local superadmin = LocalPlayer():IsSuperAdmin()
	local doorTeams = door:getKeysDoorTeams()
	local doorGroup = door:getKeysDoorGroup()
	local playerOwned = door:isKeysOwned() or table.GetFirstValue(door:getKeysCoOwners() or {}) ~= nil
	local owned = playerOwned or doorGroup or doorTeams

	if blocked then
		-- draw.SimpleTextOutlined( "Not ownable", "DoorTitle", 2, 2, Color(0,0,0, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0, al))
		-- draw.SimpleTextOutlined( "Not ownable", "DoorTitle", 0, 0, Color(220,220,220, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0, al))
	elseif not owned then
		draw.SimpleTextOutlined( DarkRP.formatMoney(GAMEMODE.Config.doorcost), "DoorPrice", 0, -68, Color(0,0,0, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))
		draw.SimpleTextOutlined( DarkRP.formatMoney(GAMEMODE.Config.doorcost), "DoorPrice", 0, -70, Color(20,255,50, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))

		draw.SimpleTextOutlined( "Press F2 to buy", "DoorTitle", 0, 0, Color(0,0,0, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))
		draw.SimpleTextOutlined( "Press F2 to buy", "DoorTitle", 0, 0, Color(220,220,220, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))
	else
		local doorInfo = {}

	    local title = door:getKeysTitle()
	    if title then
			draw.SimpleTextOutlined( title, "DoorTitle", 0, -48, Color(0,0,0, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))
			draw.SimpleTextOutlined( title, "DoorTitle", 0, -50, Color(220,220,220, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))
		end

		if playerOwned then
	        if door:isKeysOwned() then table.insert(doorInfo, {door:getDoorOwner():Nick(), team.GetColor(door:getDoorOwner():Team())}) end
	        for k,v in pairs(door:getKeysCoOwners() or {}) do
	            local ent = Player(k)
	            if not IsValid(ent) or not ent:IsPlayer() then continue end
	            table.insert(doorInfo, {ent:Nick(), team.GetColor(ent:Team())})
	        end

	        local allowedCoOwn = door:getKeysAllowedToOwn()
	        if allowedCoOwn and not fn.Null(allowedCoOwn) then
	            -- table.insert(doorInfo, DarkRP.getPhrase("keys_other_allowed"))

	            for k,v in pairs(allowedCoOwn) do
	                local ent = Player(k)
	                if not IsValid(ent) or not ent:IsPlayer() then continue end
	                table.insert(doorInfo, {ent:Nick(), team.GetColor(ent:Team())})
	            end
	        end
	    elseif doorGroup then
	        table.insert(doorInfo, doorGroup)
	    elseif doorTeams then
	        for k, v in pairs(doorTeams) do
	            if not v or not RPExtraTeams[k] then continue end

	            table.insert(doorInfo, {RPExtraTeams[k].name, RPExtraTeams[k].color})
	        end
	    elseif blocked and superadmin then
	        table.insert(doorInfo, DarkRP.getPhrase("keys_allow_ownership"))
	    elseif not blocked then
	        table.insert(doorInfo, DarkRP.getPhrase("keys_unowned"))
	        if superadmin then
	            table.insert(doorInfo, DarkRP.getPhrase("keys_disallow_ownership"))
	        end
	    end

		local y = 0
		for k, txt in pairs( doorInfo ) do
			draw.SimpleTextOutlined( istable(txt) and txt[1] or txt, "DoorInfo", 0, y + 2, Color(0,0,0, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))
			draw.SimpleTextOutlined( istable(txt) and txt[1] or txt, "DoorInfo", 0, y, istable(txt) and txt[2] or Color(220,220,220, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, al))

			y = y + 40
		end
	end

end

-- no, really, it's how falco did, if you get better solution not touching darkrp files,
-- go punch me in the face on discord: chelog#2156
timer.Simple(0, function()
	local function uhhh( whatever )
		local door = LocalPlayer():GetEyeTrace().Entity
		local doorTeams = door:getKeysDoorTeams()
		local doorGroup = door:getKeysDoorGroup()
		local playerOwned = door:isKeysOwned() or table.GetFirstValue(door:getKeysCoOwners() or {}) ~= nil
		local blocked = door:getKeysNonOwnable()
		local owned = playerOwned or doorGroup or doorTeams
	    if IsValid(door) and door:isKeysOwnable() and door:GetPos():DistToSqr(LocalPlayer():GetPos()) < 10000 then
			if not door:IsVehicle() and not blocked and not owned then
				RunConsoleCommand("darkrp", "toggleown")
				Derma_StringRequest(DarkRP.getPhrase("set_x_title", DarkRP.getPhrase("door")), DarkRP.getPhrase("set_x_title_long", DarkRP.getPhrase("door")), "", function(text)
	                RunConsoleCommand("darkrp", "title", text)
	            end)
			else
				DarkRP.openKeysMenu()
			end
		end
	end

	GAMEMODE.ShowTeam = uhhh
	usermessage.Hook("KeysMenu", uhhh)
end)

local offset = {
	["models/props_c17/door01_left.mdl"] = -4,
}

local function DrawDoors()
	local tr = LocalPlayer():GetEyeTrace()

	local door = tr.Entity
    if IsValid(door) and not door:IsVehicle() and door:isKeysOwnable() and door:GetPos():DistToSqr(LocalPlayer():GetPos()) < 40000 then
		local al = 255
		if al > 0 then
			local maxs, mins, center = door:OBBMaxs(), door:OBBMins(), door:OBBCenter()
			local off = offset[ door:GetModel() ]
			if maxs.x - mins.x > maxs.y - mins.y then
				local pos = door:LocalToWorld( Vector( center.x, maxs.y + (off or 0.1), center.z ) )
				local ang = door:LocalToWorldAngles( Angle(0,180,90) )
				cam.Start3D2D( pos, ang, 0.1 )
					drawDoor( door, al )
				cam.End3D2D()

				local pos = door:LocalToWorld( Vector( center.x, mins.y - (off or 0.1), center.z ) )
				local ang = door:LocalToWorldAngles( Angle(0,0,90) )
				cam.Start3D2D( pos, ang, 0.1 )
					drawDoor( door, al )
				cam.End3D2D()
			else
				local pos = door:LocalToWorld( Vector( maxs.x + (off or 0.1), center.y, center.z ) )
				local ang = door:LocalToWorldAngles( Angle(0,90,90) )
				cam.Start3D2D( pos, ang, 0.1 )
					drawDoor( door, al )
				cam.End3D2D()

				local pos = door:LocalToWorld( Vector( mins.x - (off or 0.1), center.y, center.z ) )
				local ang = door:LocalToWorldAngles( Angle(0,-90,90) )
				cam.Start3D2D( pos, ang, 0.1 )
					drawDoor( door, al )
				cam.End3D2D()
			end
		end
    end

end
hook.Add( "PostDrawTranslucentRenderables", "DrawDoors", DrawDoors )