
-----------------------------------------------------
SP.Active = nil;

surface.SetFont( "SP::TitleFont" );

function SP:SetNotification( title, line1, line2 )

	local textSizes = {};
	local w, h;
	local width = SP.S.MinW;

	surface.SetFont( "SP::TitleFont" );
	w, h = surface.GetTextSize( title );
	textSizes.title = { w = w, h = h };
	
	surface.SetFont( "SP::LineFont" );
	w, h = surface.GetTextSize( line1 );
	textSizes.line1 = { w = w, h = h };
	w, h = surface.GetTextSize( line2 );
	textSizes.line2 = { w = w, h = h };
	
	local isOverMin = false;
	for i, v in pairs( textSizes ) do
		if( v.w > width ) then
			width = v.w;
			isOverMin = true;
		end
	end
	
	if( isOverMin ) then
		width = width + ( SP.S.TextMargin * 2 );
	end
	
	local clr = table.Copy( SP.S.BackgroundColor );
	clr.a = SP.S.StartVisibility;
	
	SP.Active = {
		title = title,
		line1 = line1,
		line2 = line2,
		visibility = SP.S.StartVisibility,
		added = os.time(),
		textSizes = textSizes,
		width = width,
		clr = clr
	};

end


net.Receive( "SP::SetNotification", function( _ )
	local index = net.ReadString();
	local ply = Entity( net.ReadFloat() );
	local arg2 = net.ReadString();

	// fix for darkrp messages
	if( ply && ply.SPArrest && ply.SPArrest > CurTime() ) then
		return;
	end
	
	if( !IsValid( ply ) || !SP.M[ index ] ) then
		return;
	end
	
	local title, line1, line2;
	title = SP.M[ index ].title;
	
	if( index == "Arrested" ) then
		ply.SPArrest = CurTime() + 2;
	end
	
	ply = ply:Nick();
	if( arg2 ) then
		line1, line2 = SP.M[ index ].text( ply, arg2 );
	else
		line1, line2 = SP.M[ index ].text( ply );
	end
	
	line1 = string.upper( line1 );
	line2 = string.upper( line2 );

	SP:SetNotification( title, line1, line2 );
end );

hook.Add( "HUDPaint", "SP::HUDPaint", function()

	if( !SP.Active ) then
		return; 
	end
	
	local w, h, clr = SP.Active.width, SP.S.MinH, SP.Active.clr;
	
	local x = ScrW() / 2 - w / 2;
	local y = SP.S.MarginFromTop;
	
	if( !SP.Active.fadeOut && clr.a < SP.S.MaxVisibility ) then
		clr.a = clr.a + 1;
		
		if( clr.a >= SP.S.MaxVisibility ) then
			SP.Active.fadeOut = os.time();
		end
	else
		if( ( os.time() - SP.Active.fadeOut ) >= SP.S.StayAtMaxFor ) then
			clr.a = clr.a - 1;
		end
		
		if( clr.a <= SP.S.EndVisibility ) then
			SP.Active = nil;
			return;
		end
	end
	
	local outlineClr = table.Copy( SP.S.OutlineColor );
	outlineClr.a = clr.a;
	surface.SetDrawColor( outlineClr );
	surface.DrawOutlinedRect( x - 1, y - 1, w + 2, h + 2 );
	
	surface.SetDrawColor( clr );
	surface.DrawRect( x, y, w, h );
	
	outlineClr = table.Copy( SP.S.TextOutline );
	outlineClr.a = clr.a;
	
	local titleClr = table.Copy( SP.S.TitleColor );
	titleClr.a = clr.a;
	draw.SimpleTextOutlined( SP.Active.title, "SP::TitleFont", ScrW() / 2 - SP.Active.textSizes.title.w / 2,
	y + 5, titleClr, 0, TEXT_ALIGN_TOP, 1, outlineClr );
	
	local textClr = table.Copy( SP.S.LineColor );
	textClr.a = clr.a * 1.5;
	
	draw.SimpleTextOutlined( SP.Active.line1, "SP::LineFont", ScrW() / 2 - SP.Active.textSizes.line1.w / 2,
	y + SP.Active.textSizes.title.h + 15, textClr, 0, TEXT_ALIGN_TOP, 1, outlineClr );

	draw.SimpleTextOutlined( SP.Active.line2, "SP::LineFont", ScrW() / 2 - SP.Active.textSizes.line2.w / 2,
	y + SP.Active.textSizes.title.h + SP.Active.textSizes.line1.h + 15, textClr, 0, TEXT_ALIGN_TOP, 1, outlineClr );	
end );