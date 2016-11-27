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
	record = strTok( httpPostRequest(
		level.dvar[ "surf_api_host" ],
		80,
		"sys/cod4/backend.php?action=surfworldrecord",
		"apikey=" + level.dvar[ "surf_api_key" ] + "&mapname=" + level.script
	), ";" );

	// For testing purposes, or incase the webserver is down
	if( record.size < 2 ) {
		record = [];
		record[0] = "No record set";
		record[1] = 0;
	}

	level.worldRecord = [];
	level.worldRecord[ "player" ] = record[0];
	level.worldRecord[ "time" ] = int( record[1] );

	thread onPlayerSpawned();
	thread printRecords();
}

printRecords() {
	for(;;) {
		wait level.dvar[ "surf_record_print_interval" ];
		printMapRecord();
		
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) {
			if( players[i].sessionstate == "playing" )
				players[i] printPersonalRecord();
		}
	}
}

printMapRecord() {
	if( level.worldRecord[ "player" ] != "0" && level.worldRecord[ "time" ] != 0 )
		iPrintLn( "^3Map record^7: " + toTime( level.worldRecord[ "time" ] ) + " (" + level.worldRecord[ "player" ] + "^7)" );
	else
		iPrintLn( "^3Map record^7: No record yet" );
}

printPersonalRecord() {
	if( isDefined( self.data ) && isDefined( self.data.size ) && int( self.data[ "record" ] ) != 0 )
		self iPrintLn( "^1Personal Best^7: " + toTime( int( self.data[ "record" ] ) ) );
	else
		self iPrintLn( "^1Personal Best^7: You have not finished yet" );
}

onPlayerSpawned() {
	for(;;) {
		level waittill( "player_spawn", player );

		if( isDefined( player.clock ) )
			player.clock destroy();

		player thread startmapTrigger();
		player printPersonalRecord();
	}
}

startmapTrigger() {
	self endon( "disconnect" );
	self endon( "spawned" );

	trigger = getEntArray( "trigger_startmap", "targetname" );
	if( trigger.size == 0 ) {
		iPrintLnBold( "WARNING: trigger_startmap not found!" );
		return;
	}

	if( trigger.size > 1 ) {
		iPrintLnBold( "WARNING: Found multiple entities with the targetname trigger_startmap!" );
		return;
	}

	for(;;) {
		for(;;) {
			trigger[0] waittill( "trigger", player );
			if( player == self )
				break;
		}
		
		if( !isDefined( self.inChallenge ) || !self.inChallenge ) {
			if( isDefined( self.clock ) )
				self.clock destroy();
	
			while( self isTouching( trigger[0] ) )
				wait .05;
			
			self notify( "left_spawn" );
	
			self.startTime = getTime();
	
			self.clock = newClientHudElem( self );
			self.clock.horzAlign = "left";
			self.clock.vertAlign = "bottom";
			self.clock.alignX = "left";
			self.clock.alignY = "bottom";
			self.clock.x = 8;
			self.clock.y = -16;
			self.clock.font = "default";
			self.clock.color = ( .165, .498, .702 ); //self.clock.color = ( .612, .153, .69 );
			self.clock.fontscale = 1.4;
			self.clock.label = &"^8Time: ^7&&1";
			self.clock.hidewheninmenu = true;
			self.clock setTenthsTimerUp( .05 );
	
			self thread endmapTrigger();
		}
	}
}

endmapTrigger() {
	self endon( "disconnect" );
	self endon( "spawned" );
	self endon( "left_spawn" );

	trigger = getEntArray( "trigger_endmap", "targetname" );
	if( trigger.size == 0 ) {
		iPrintLnBold( "WARNING: trigger_endmap not found!" );
		return;
	}

	if( trigger.size > 1 ) {
		iPrintLnBold( "WARNING: Found multiple entities with the targetname trigger_endmap!" );
		return;
	}

	for(;;) {
		trigger[0] waittill( "trigger", player );

		if( player == self )
			break;
	}

	maptime = getTime() - self.startTime;
	
	self notify( "map_finished" );

	if( isDefined( self.clock ) )
		self.clock destroy();

	if( isDefined( level.surfDifficulty ) ) {
		switch( level.surfDifficulty ) {
		case "easy":
			self surf\_rank::giveRankXP( 60 );
			break;
			
		case "intermediate":
			self surf\_rank::giveRankXP( 75 );
			break;
			
		case "hard":
			self surf\_rank::giveRankXP( 90 );
			break;
			
		default:
			self surf\_rank::giveRankXP( 60 );
			break;
		}
	} else
		self surf\_rank::giveRankXP( 60 );
		
	if( maptime < int( self.data[ "record" ] ) || int( self.data[ "record" ] ) == 0 )
		self.data[ "record" ] = maptime;
	
	if( maptime < level.worldRecord[ "time" ] || level.worldRecord[ "time" ] == 0 ) {
		iPrintLn( "^3" + self.name + " ^7has finished " + level.script + " in " + toTime( maptime ) + " (^1World Record^7)!" );
		self surf\_rank::giveRankXP( 500 );
		
		level.worldRecord[ "player" ] = self.name;
		level.worldRecord[ "time" ] = maptime;
	} else
		iPrintLn( "^3" + self.name + " ^7has finished " + level.script + " in " + toTime( maptime ) + "!" );
		
	self.score++;

	if( isDefined( self.startTime ) ) {
		httpPostRequest(
			level.dvar[ "surf_api_host" ],
			80,
			"sys/cod4/backend.php?action=surfsubmitrecord",
			"apikey=" + level.dvar[ "surf_api_key" ] +
			"&guid=" + self getGuid() + "&name=" + stripColor( self.name ) +
			"&mapname=" + level.script +
			"&maptime=" + maptime,
			false
		);
	}
}