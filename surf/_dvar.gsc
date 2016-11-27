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

setupDvars() {
	level.dvar = [];

	level.dvar[ "logPrint" ] = 1;

	setDvar( "sv_fps", "20" );
	setDvar( "g_speed", "250" );
	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "g_deadChat", 1 );
	
	setDvar( "mod_author", "atrX" );
	makeDvarServerInfo( "mod_author", "atrX" );
	
	setDvar( "g_TeamColor_Allies", "1 1 1 1" );
	setDvar( "g_TeamName_Allies", "Surfers" );
	setDvar( "g_TeamName_Axis", "" );
	setDvar( "g_TeamIcon_Allies", "mtl_team_surfers" );
	setDvar( "g_TeamIcon_Axis", "" );

	addDvar( "surf_timelimit", "surf_timelimit", 45, 1, 12000, "int" );

	addDvar( "surf_mapvote_time", "surf_mapvote_time", 20, 1, 600, "int" );
	addDvar( "surf_extend_timer_time", "surf_extend_timer_time", 30, 1, 12000, "int" );

	addDvar( "xp_multiplier", "xp_multiplier", 1, 0.1, 12000, "float" );
	addDvar( "xp_events", "xp_events", 1, 0, 1, "int" );
	addDvar( "xp_events_player_count", "xp_events_player_count", 10, 0, 64, "int" );
	
	addDvar( "surf_record_print_interval", "surf_record_print_interval", 60, 1, 3600, "int" );
	
	addDvar( "surf_infinite_ammo", "surf_infinite_ammo", 1, 0, 1, "int" );
	
	addDvar( "surf_challenge_request_time", "surf_challenge_request_time", 15, 1, 60, "int" );
	addDvar( "surf_challenge_countdown_time", "surf_challenge_countdown_time", 3, 1, 60, "int" );
	addDvar( "surf_challenge_xp_reward", "surf_challenge_xp_reward", 50, 1, 12000, "int" );

	addDvar( "surf_api_host", "surf_api_host", "localhost", "", "", "string" );
	addDvar( "surf_api_key", "surf_api_key", "e2SlkSVc4WgeinOzD6HgFncrWP4eH9wc", "", "", "string" );

	addDvar( "motd", "surf_motd", "Welcome to ^2CoD4 ^3Surf^7!", "", "", "string" );
}

addDvar( scriptName, varName, varDefault, min, max, type ) {
	if( getDvar( varName ) != "" ) {
		switch( type ) {
		case "int":
			definition = getDvarInt( varName );
			break;

		case "float":
			definition = getDvarFloat( varName );
			break;

		default:
			definition = getDvar( varName );
			break;
		}
	}
	else
		definition = varDefault;

	if( type == "int" || type == "float" ) {
		if( min != 0 && definition < min )
			definition = min;
		if( max != 0 && definition > max )
			definition = max;
	}

	level.dvar[ scriptName ] = definition;
}