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
	setDvar( "surf_votemap", "0" );

	level.surfTimerExtended = false;
	
	thread monitor();
	
	rotation = [];
	for( i = 1; getDvar( "surf_maprotation" + i ) != ""; i++ ) {
		rotationPart = getDvar( "surf_maprotation" + i );
		rotationPart = strTok( rotationPart, " " );

		for( j = 0; j < rotationPart.size; j++ ) {
			if( toLower( rotationPart[j] ) != level.script )
				rotation[ rotation.size ] = rotationPart[j];
		}
	}
	
	// Set the rotation dvar for voting so it doesn't switch to a stock map
	// Cons of using custom dvars for this kind of stuff
	if( rotation.size > 0 )
		randomMap = rotation[ randomInt( rotation.size ) ];
	else
		randomMap = "mp_surf_utopia";
	
	setDvar( "sv_maprotation", "gametype surf map " + randomMap );
	setDvar( "sv_maprotationcurrent", "gametype surf map " + randomMap );
}

monitor() {
	level endon( "mapvote_started" );

	for(;;) {
		if( getDvarInt( "surf_votemap" ) == 1 ) {
			setDvar( "surf_votemap", "0" );

			wait 3;
			level thread mapvote();

			break;
		}

		wait .1;
	}
}

mapvote() {
	level notify( "mapvote_started" );

	// Amount of maps in the vote menu
	mapCount = 5;
	level.mapvoteMaps = [];

	// Get all maps from rotations
	rotation = [];
	for( i = 1; getDvar( "surf_maprotation" + i ) != ""; i++ ) {
		rotationPart = getDvar( "surf_maprotation" + i );
		rotationPart = strTok( rotationPart, " " );

		for( j = 0; j < rotationPart.size; j++ ) {
			if( toLower( rotationPart[j] ) != level.script )
				rotation[ rotation.size ] = rotationPart[j];
		}
	}

	// Select random maps
	for( i = 0; i < mapCount; i++ ) {
		level.mapvoteMaps[i][ "map" ] = rotation[ randomInt( rotation.size ) ];
		level.mapvoteMaps[i][ "votes" ] = 0;
		newRotation = [];
		for( j = 0; j < rotation.size; j++ ) {
			if( rotation[j] != level.mapvoteMaps[i][ "map" ] )
				newRotation[ newRotation.size ] = rotation[j];
		}
		rotation = newRotation;
	}

	for( i = 0; i < level.mapvoteMaps.size; i++ ) {
		difficulty = surf\_difficulty::getDifficulty( level.mapvoteMaps[i][ "map" ] );
		mapname = strTok( level.mapvoteMaps[i][ "map" ], "_" )[2];
		if( isDefined( difficulty ) )
			setMapvoteDvar( "surf_mapvote_map_" + ( i + 1 ), mapname + " (" + difficulty + ")" );
		else
			setMapvoteDvar( "surf_mapvote_map_" + ( i + 1 ), mapname );
	}

	// Open vote menu and start monitoring menuresponses
	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ ) {
		players[i] thread mapvoteTrack();
		players[i] openMenu( game[ "menu_mapvote" ] );
	}

	wait( level.dvar[ "surf_mapvote_time" ] );
	level notify( "mapvote_ended" );
	
	// Close menu
	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ ) {
		players[i] closeMenu();
		players[i] closeInGameMenu();
	}

	winner = level.mapvoteMaps[0];
	for( i = 1; i < level.mapvoteMaps.size; i++ ) {
		if( level.mapvoteMaps[i][ "votes" ] > winner[ "votes" ] )
			winner = level.mapvoteMaps[i];
	}
	
	// We'll want to update people's ranks in the database
	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ ) {
		httpPostRequest(
			level.dvar[ "surf_api_host" ],
			80,
			level.dvar[ "surf_api_path" ] + "/backend.php?action=surfsaverank",
			"apikey=" + level.dvar[ "surf_api_key" ] +
			"&guid=" + players[i] getGuid() +
			"&name=" + stripColor( players[i].name ) +
			"&rankxp=" + players[i].pers[ "rankxp" ] +
			"&rank=" + ( players[i].pers[ "rank" ] + 1 ),
			false
		);
	}

	iPrintLn( "^7Changing map to: ^3" + winner[ "map" ] );
	
	setDvar( "sv_maprotationcurrent", "gametype surf map " + winner[ "map" ] );
	wait 5;
	exitLevel( 0 );
}

mapvoteTrack() {
	level endon( "mapvote_ended" );

	for(;;) {
		self waittill( "menuresponse", menu, response );

		if( menu == "mapvote" ) {
			level.mapvoteMaps[ int( response ) ][ "votes" ]++;
			break;
		}
	}
}

setMapvoteDvar( dvar, value ) {
	setDvar( dvar, value );

	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
		players[i] setClientDvar( dvar, value );
}

extendTimer() {
	if( level.surfTimerExtended ) {
		iPrintLn( "Timer has already been extended." );
		return;
	}
	
	if( isDefined( level.extendTimerVoteStarted ) && level.extendTimerVoteStarted ) {
		iPrintln( "A vote to extend the timer is already in progress." );
		return;
	}
	
	level.extendTimerVoteStarted = true;
	level.extendTimerVotes = [];
	
	// Open vote menu and start monitoring menuresponses
	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ ) {
		players[i] thread extendTimerTrack();
		players[i] openMenu( game[ "menu_extend_timer" ] );
	}

	wait( level.dvar[ "surf_mapvote_time" ] );
	level notify( "extend_timer_vote_ended" );

	votes = [];
	votes[ "yes" ] = 0;
	votes[ "no" ] = 0;
	
	for( i = 0; i < level.extendTimerVotes.size; i++ ) {
		if( level.extendTimerVotes[i] == 0 )
			votes[ "yes" ]++;
		else
			votes[ "no" ]++;
	}
	
	if( votes[ "yes" ] > votes[ "no" ] ) {
		level.timelimit += level.dvar[ "surf_extend_timer_time" ];
		level.updateTimer = true;
		level.surfTimerExtended = true;
		
		iPrintLn( "Map timer was extended as the result of a vote." );
	} else {
		iPrintLn( "Vote failed." );
	}
	
	level.extendTimerVoteStarted = false;
	
	// Close menu
	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ ) {
		players[i] closeMenu();
		players[i] closeInGameMenu();
	}
}

extendTimerTrack() {
	level endon( "extend_timer_vote_ended" );

	for(;;) {
		self waittill( "menuresponse", menu, response );

		if( menu == game[ "menu_extend_timer" ] ) {
			level.extendTimerVotes[ level.extendTimerVotes.size ] = int( response );
			break;
		}
	}
}