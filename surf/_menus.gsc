/*
	Call of Duty 4: Surf Mod
	Copyright (C) 2016  Jordy Rymenants

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include surf\_util;

main() {
	game[ "menu_ingame_main" ] = "ingame_main";
	game[ "menu_customization" ] = "customization";
	game[ "menu_call_vote" ] = "call_vote";
	game[ "menu_mapvote" ] = "mapvote";
	game[ "menu_extend_timer" ] = "extend_timer";
	game[ "menu_quickcommands" ] = "quickcommands";

	precacheMenu( game[ "menu_ingame_main" ] );
	precacheMenu( game[ "menu_customization" ] );
	precacheMenu( game[ "menu_call_vote" ] );
	precacheMenu( game[ "menu_mapvote" ] );
	precacheMenu( game[ "menu_extend_timer" ] );
	precacheMenu( game[ "menu_quickcommands" ] );
	precacheMenu( "callvote" );

	precacheShader( "black" );
	precacheShader( "white" );

	level thread onPlayerConnect();
}

onPlayerConnect() {
	level endon( "game_ended" );

	for(;;) {
		level waittill( "connected", player );
		player setClientDvar( "g_scriptMainMenu", game[ "menu_ingame_main" ] );
		player thread onMenuResponse();
	}
}

onMenuResponse() {
	self endon( "disconnect" );

	for(;;) {
		self waittill( "menuresponse", menu, response );

		if( response == "back" ) {
			self closeMenu();
			self closeInGameMenu();
			continue;
		}

		if( menu == game[ "menu_ingame_main" ] ) {
			switch( response ) {
			case "allies":
			case "axis":
			case "autoassign":
				self closeMenu();
				self closeInGameMenu();

				self thread surf\_mod::spawnPlayer();
				break;

			case "spectator":
				self closeMenu();
				self closeInGameMenu();

				self thread surf\_mod::spawnSpectator();
				break;
			}
		} else if( menu == game[ "menu_customization" ] ) {
			item = strTok( response, ":" );
			
			// Check if the item in question requires VIP
			// If we're not VIP, don't event bother executing the rest of the code
			if( isArray( item ) && item.size > 2 && item[2] == "vip" && !self surf\_vip::isVip() )
				continue;

			if( item[0] == "vip_item" )
				id = item[1];
			else
				id = int( item[1] ) - 1;

			// First element = item type (eg: weapon, character, hands)
			switch( item[0] ) {
			case "weapon":
				if( self surf\_items::itemUnlocked( id ) ) {
					self setStat( 100, id );
					self.pers[ "weapon" ] = id;
				}
				break;

			case "character":
				if( self surf\_items::characterUnlocked( id ) ) {
					self setStat( 101, id );
					self.pers[ "character" ] = id;
				}
				break;

			case "hands":
				if( self surf\_items::handsUnlocked( id ) ) {
					self setStat( 102, id );
					self.pers[ "hands" ] = id;
				}
				break;

			case "knife":
				if( self surf\_items::knifeUnlocked( id ) ) {
					self setStat( 103, id );
					self.pers[ "knife" ] = id;
				}
				break;
				
			case "trail":
				if( self surf\_items::trailUnlocked( id ) ) {
					self setStat( 104, id );
					self.pers[ "trail" ] = id;
				}
				break;
				
			case "vip_item":
				self surf\_vip::toggleVipItem( id );
				break;
			}
		} else if( menu == game[ "menu_quickcommands" ] ) {
			switch( response ) {
			case "3rdperson":
				if( self getStat( 988 ) == 0 ) {
					self iPrintln( "Third Person Camera Enabled" );
					self setClientDvar( "cg_thirdperson", 1 );
					self setStat( 988, 1 );
				} else {
					self iPrintln( "Third Person Camera Disabled" );
					self setClientDvar( "cg_thirdperson", 0 );
					self setStat( 988, 0 );
				}
				break;
				
			case "restart":
				self surf\_mod::respawn();
				break;
				
			case "fullbright":
				if( self getStat( 989 ) == 0 ) {
					self iPrintln( "Fullbright Enabled" );
					self setClientDvar( "r_fullbright", 1 );
					self setStat( 989, 1 );
				} else {
					self iPrintln( "Fullbright Disabled" );
					self setClientDvar( "r_fullbright", 0 );
					self setStat( 989, 0 );
				}
				break;
				
			case "spectator_names":
				if( self getStat( 987 ) == 1 ) {
					self iPrintln( "Show Spectator Names Enabled" );
					self setStat( 987, 0 );
				} else {
					self iPrintln( "Show Spectator Names Disabled" );
					self setStat( 987, 1 );
				}
				break;
			
			case "toggle_hud":
				if( self getStat( 986 ) == 1 ) {
					self iPrintln( "Show HUD Enabled" );
					self setClientDvar( "cg_draw2d", 0 );
					self setStat( 986, 0 );
				} else {
					self iPrintln( "Show HUD Disabled" );
					self setClientDvar( "cg_draw2d", 1 );
					self setStat( 986, 1 );
				}
				break;
			
			case "toggle_gun":
				if( self getStat( 985 ) == 1 ) {
					self iPrintln( "Show Gun Enabled" );
					self setClientDvar( "cg_drawgun", 0 );
					self setStat( 985, 0 );
				} else {
					self iPrintln( "Show Gun Disabled" );
					self setClientDvar( "cg_drawgun", 1 );
					self setStat( 985, 1 );
				}
				break;
			}
		} else if( menu == game[ "menu_call_vote" ] ) {
			if( response == "surf_save_rank" ) {
				players = getEntArray( "player", "classname" );
				for( i = 0; i < players.size; i++ ) {
					httpPostRequestAsync(
						level.dvar[ "surf_api_host" ],
						80,
						"sys/cod4/backend.php?action=surfsaverank",
						"apikey=" + level.dvar[ "surf_api_key" ] +
						"&guid=" + players[i] getGuid() +
						"&name=" + stripColor( players[i].name ) +
						"&rankxp=" + players[i].pers[ "rankxp" ] +
						"&rank=" + ( players[i].pers[ "rank" ] + 1 )
					);
				}
			} else if( response == "surf_vote_extend" ) {
				thread surf\_vote::extendTimer();
			}
		}
	}
}