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
	maps\mp\_load::main();

	if( !isDefined( game[ "allies" ] ) )
		game[ "allies" ] = "marines";
	if( !isDefined( game[ "axis" ] ) )
		game[ "axis" ] = "opfor";

	if( getDvar( "scr_allies" ) != "" )
		game[ "allies" ] = getDvar( "scr_allies" );
	if( getDvar( "scr_axis" ) != "" )
		game[ "axis" ] = getDvar( "scr_axis" );

	precacheStatusIcon( "hud_status_connecting" );
	precacheStatusIcon( "hud_status_dead" );

	level.splitscreen = isSplitScreen();
	level.xenon = false;
	level.ps3 = false;
	level.console = false;
	level.teamBased = true;
	level.onlineGame = true;
	level.oldschool = false;
	level.rankedMatch = getDvarInt( "sv_pure" );
	level.gameEnded = false;

	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\gametypes\_hud::init();

	surf\_dvar::setupDvars();
	surf\_vip::main();
	surf\_items::main();
	surf\_menus::main();
	surf\_rank::main();
	if( !isDefined( level.surfNoTimer ) || !level.surfNoTimer )
		surf\_records::main();
	surf\_vote::main();
	surf\_spectator::main();
	surf\_b3::main();

	setClientNameMode( "auto_change" );

	spawnpoints = getEntArray( "mp_dm_spawn", "classname" );
	if( !spawnpoints.size ) {
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for( i = 0; i < spawnpoints.size; i++ )
		spawnpoints[i] placeSpawnPoint();

	if( !isDefined( game[ "state" ] ) )
		game[ "state" ] = "playing";

	level.mapended = false;
	level.timelimit = level.dvar[ "surf_timelimit" ];

	if( !isDefined( level.surfDifficulty ) )
		level.surfDifficulty = surf\_difficulty::getDifficulty( level.script );
	
	// If the current map is not a surf map, change the map to a random map in the rotation
	if( !isSubStr( level.script, "mp_surf_" ) ) {
		wait 1;
		exitLevel( 0 );
	}

	thread startGame();
	thread mapLogic();
}

mapLogic() {
	teleporters = getEntArray( "trigger_teleport", "targetname" );
	for( i = 0; i < teleporters.size; i++ )
		teleporters[i] thread teleporter();

	boosters = getEntArray( "trigger_boost", "targetname" );
	for( i = 0; i < boosters.size; i++ )
		boosters[i] thread booster();
		
	speedBoosts = getEntArray( "trigger_speed", "targetname" );
	for( i = 0; i < speedBoosts.size; i++ )
		speedBoosts[i] thread speedBoost();
}

speedBoost() {
	speedScale = strTok( self.target, " " );
	speedScale = ( speedScale[0], speedScale[1], speedScale[2] );
	
	for(;;) {
		self waittill( "trigger", player );
		player setVelocity( player getVelocity() * speedScale );
	}
}

booster() {
	speed = strTok( self.target, " " );
	speed = ( int( speed[0] ), int( speed[1] ), int( speed[2] ) );

	for(;;) {
		self waittill( "trigger", player );
		player setVelocity( player getVelocity() + speed );
	}
}

teleporter() {
	if( !isDefined( self.target ) ) {
		print( "WARNING: teleporter without target!\n" );
		return;
	}

	targets = getEntArray( self.target, "targetname" );
	if( targets.size == 0 ) {
		print( "WARNING: trigger without target. End thread!\n" );
		return;
	}

	for(;;) {
		self waittill( "trigger", player );

		target = targets[ randomInt( targets.size ) ];

		player setOrigin( target.origin );
		player setPlayerAngles( target.angles );

		if( isDefined( self.script_noteworthy ) && self.script_noteworthy == "slowdown" )
			player setVelocity( ( 0, 0, 0 ) );
		else
			player setVelocityBase(
				vectorScale(
					anglesToForward( target.angles ),
					length( player getVelocityBase() )
				)
			);
		wait .05;
	}
}

dummy() {
	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}

Callback_PlayerConnect() {
	thread dummy();

	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	self.statusicon = "";
	
	setDvar( "surf_respawn_" + self getEntityNumber(), 0 );

	level notify( "connected", self );

	if( !level.splitscreen )
		iPrintLn( &"MP_CONNECTED", self );

	logPrint( "J;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );

	if( game[ "state" ] == "intermission" ) {
		spawnIntermission();
		return;
	}

	level endon( "intermission" );

	self.pers[ "team" ] = "spectator";
	self.sessionteam = "spectator";
	
	result = strTok( httpPostRequest(
		level.dvar[ "surf_api_host" ],
		80,
		"sys/cod4/backend.php?action=surfauth",
		"apikey=" + level.dvar[ "surf_api_key" ] + "&guid=" + self getGuid() + "&name=" + stripColor( self.name ) + "&mapname=" + level.script
	), ";" );
	if( result.size > 0 ) {
		self.data = [];
		self.data[ "record" ] = "0"; // Because it was throwing errors
		
		for( i = 0; i < result.size; i++ ) {
			field = strTok( result[i], ":" );
			self.data[ field[0] ] = field[1];
		}
	}
	
	self.pers[ "rankxp" ] = self.data[ "rankxp" ]; //self maps\mp\gametypes\_persistence::statGet( "rankxp" );
	if( !isDefined( self.pers[ "rankxp" ] ) )
		self.pers[ "rankxp" ] = 0;
	self.pers[ "rankxp" ] = int( self.pers[ "rankxp" ] );
	rankId = surf\_rank::getRankForXp( self.pers[ "rankxp" ] );
	self.pers[ "rank" ] = rankId;
	surf\_rank::updateRankStats( self, rankId );
	self setRank( rankId );

	/**
 	 * score = amount of times a player has finished the map since connecting
	 * kills = speed
	 * assists = FPS
 	 * deaths = client number
	 */
	self.score = 0;
	self.kills = 0;
	self.assists = 0;
	self.deaths = self getEntityNumber();

	self setClientDvar( "surf_player_vip", self surf\_vip::isVip() );

	self thread maps\mp\gametypes\_hud_message::initNotifyMessage();
	
	self.joined = true;

	self spawnSpectator();

	self openMenu( game[ "menu_ingame_main" ] );
}

Callback_PlayerDisconnect() {
	level notify( "disconnected", self );

	if( !level.splitscreen )
		iPrintLn( &"MP_DISCONNECTED", self );

	logPrint( "Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n" );
	
	if( isDefined( self.joined ) ) {
		httpPostRequest(
			level.dvar[ "surf_api_host" ],
			80,
			"sys/cod4/backend.php?action=surfsaverank",
			"apikey=" + level.dvar[ "surf_api_key" ] +
			"&guid=" + self getGuid() +
			"&name=" + stripColor( self.name ) +
			"&rankxp=" + self.pers[ "rankxp" ] +
			"&rank=" + ( self.pers[ "rank" ] + 1 ),
			false
		);
	}
}

Callback_PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration ) {
	self endon( "spawned" );
	self notify( "death" );
	
	if( self.sessionteam == "spectator" )
		return;
		
	if( sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";
	
	self allowSpectateTeam( "allies", false );
	self allowSpectateTeam( "axis", false );
	self allowSpectateTeam( "freelook", false );
	self allowSpectateTeam( "none", true );

	obituary( self, attacker, sWeapon, sMeansOfDeath );

	wait .1;
	
	self respawn();
}

spawnPlayer() {
	self endon( "disconnect" );
	self notify( "spawned" );

	self.spawnTime = getTime();

	resetTimeout();

	self stopShellShock();

	self.pers[ "team" ] = "allies";
	self.team = self.pers[ "team" ];
	self.sessionteam = "allies";
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.statusicon = "";

	if( !self surf\_items::itemUnlocked( self getStat( 100 ) ) )
		self setStat( 100, 0 );
	if( !self surf\_items::characterUnlocked( self getStat( 101 ) ) )
		self setStat( 101, 0 );
	if( !self surf\_items::handsUnlocked( self getStat( 102 ) ) )
		self setStat( 102, 0 );
	if( !self surf\_items::knifeUnlocked( self getStat( 103 ) ) )
		self setStat( 103, 0 );
	if( !self surf\_items::trailUnlocked( self getStat( 104 ) ) )
		self setStat( 104, 0 );

	self.pers[ "weapon" ] = self getStat( 100 );
	self.pers[ "character" ] = self getStat( 101 );
	self.pers[ "hands" ] = self getStat( 102 );
	self.pers[ "knife" ] = self getStat( 103 );
	self.pers[ "trail" ] = self getStat( 104 );

	// Check if somehow a non-vip got access to a vip item
	// (eg: when one was vip but no longer is)
	if( !self surf\_vip::isVip() ) {
		if( surf\_vip::isVipItem( "weapon", self.pers[ "weapon" ] ) ) {
			self.pers[ "weapon" ] = 0;
			self setStat( 100, 0 );
		}
		
		if( surf\_vip::isVipItem( "character", self.pers[ "character" ] ) ) {
			self.pers[ "character" ] = 0;
			self setStat( 101, 0 );
		}
		
		if( surf\_vip::isVipItem( "hands", self.pers[ "hands" ] ) ) {
			self.pers[ "hands" ] = 0;
			self setStat( 102, 0 );
		}
		
		if( surf\_vip::isVipItem( "knife", self.pers[ "knife" ] ) ) {
			self.pers[ "knife" ] = 0;
			self setStat( 103, 0 );
		}
		
		if( surf\_vip::isVipItem( "trail", self.pers[ "trail" ] ) ) {
			self.pers[ "trail" ] = 0;
			self setStat( 104, 0 );
		}
	} else {
		// Set VIP items
		self surf\_vip::setVipItem( "statusicon", self getStat( 200 ) );
	}

	spawnpoints = getEntArray( "mp_dm_spawn", "classname" );
	spawnpoint = spawnpoints[ randomInt( spawnpoints.size ) ];

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error( "NO mp_dm_spawn SPAWNPOINTS IN MAP" );

	self.maxhealth = 100;
	self.health = self.maxhealth;
	self setMoveSpeedScale( 1 );
	self allowSprint( false );
	self allowAds( false );

	self thread setCustomization();

	if( isDefined( self.speedHud ) )
		self.speedHud destroy();

	self.speedHud = newClientHudElem( self );
	self.speedHud.horzAlign = "left";
	self.speedHud.vertAlign = "bottom";
	self.speedHud.alignX = "left";
	self.speedHud.alignY = "bottom";
	self.speedHud.x = 8;
	self.speedHud.y = -32;
	self.speedHud.font = "default";
	self.speedHud.color = ( .165, .498, .702 ); //self.speedHud.color = ( .612, .153, .69 );
	self.speedHud.fontscale = 1.4;
	self.speedHud.label = &"^8Speed: ^7&&1";
	self.speedHud.hidewheninmenu = true;
	self thread updateSpeedHud();
	
	self thread updateStats();

	waittillframeend;
	
	if( self getStat( 988 ) == 1 )
		self setClientDvar( "cg_thirdperson", 1 );
	if( self getStat( 989 ) == 1 )
		self setClientDvar( "r_fullbright", 1 );
	if( self getStat( 986 ) == 1 )
		self setClientDvar( "cg_draw2d", 0 );
	if( self getStat( 985 ) == 1 )
		self setClientDvar( "cg_drawgun", 0 );
	
	self notify( "spawned_player" );
	level notify( "player_spawn", self );

	self thread surf\_surf::surf();
	self thread surf\_bunnyhop::bunnyhop();
}

spawnSpectator( origin, angles ) {
	self notify( "spawned" );

	resetTimeout();

	self stopShellShock();

	self.pers[ "team" ] = "spectator";
	self.sessionteam = "spectator";
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.statusicon = "";

	self setSpectatorPermissions();

	if( isDefined( self.clock ) )
		self.clock destroy();

	if( isDefined( self.speedHud ) )
		self.speedHud destroy();
	
	if( isDefined( self.spectatorList ) )
		self.spectatorList destroy();

	if( isDefined( origin ) && isDefined( angles ) )
		self spawn( origin, angles );
	else {
		spawnpoints = getEntArray( "mp_global_intermission", "classname" );
		if( spawnpoints.size > 0 ) {
			spawnpoint = spawnpoints[ randomInt( spawnpoints.size ) ];
			self spawn( spawnpoint.origin, spawnpoint.angles );
		} else {
			 self spawn( ( 0, 0, 0 ), ( 0, 0, 0 ) );
		}
	}

	level notify( "spectator_spawn", self );
}

spawnIntermission() {
	self notify( "spawned" );

	resetTimeout();

	self stopShellShock();

	self.sessionstate = "intermission";
	self.spectatorclient = -1;

	spawnpoints = getEntArray( "mp_global_intermission", "classname" );
	if( spawnpoints.size > 0 ) {
		spawnpoint = spawnpoints[ randomInt( spawnpoints.size ) ];
		self spawn( spawnpoint.origin, spawnpoint.angles );
	} else {
		 self spawn( ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
}

respawn() {
	self thread spawnPlayer();
}

setCustomization() {
	self detachAll();

	self setModel( level.characterInfo[ self.pers[ "character" ] ][ "playermodel" ] );
	self setViewModel( level.handsInfo[ self.pers[ "hands" ] ][ "viewhands" ] );

	self SetActionSlot( 1, "nightvision" );

	// Just incase
	self takeAllWeapons();

	self giveWeapon( level.itemInfo[ self.pers[ "weapon" ] ][ "item" ] );
	self giveMaxAmmo( level.itemInfo[ self.pers[ "weapon" ] ][ "item" ] );

	self giveWeapon( level.knivesInfo[ self.pers[ "knife" ] ][ "knife" ] );

	wait .05;
	self switchToWeapon( level.itemInfo[ self.pers[ "weapon" ] ][ "item" ] );
	
	if( self.pers[ "trail" ] != 0 ) // 0 = none
		self thread trail( level.trailInfo[ self.pers[ "trail" ] ][ "trail" ] );
}

startGame() {
	level.starttime = getTime();
	level.timeLeft = level.timelimit;

	if( level.timelimit > 0 ) {
		level.clock = newHudElem();
		level.clock.horzAlign = "left";
		level.clock.vertAlign = "top";
		level.clock.x = 8;
		level.clock.y = 2;
		level.clock.font = "default";
		level.clock.fontscale = 1.6;
		level.clock.hidewheninmenu = true;
		level.clock setTimer( level.timelimit * 60 );
	}

	for(;;) {
		checkTimeLimit();
		wait 1;
	}
}

endMap() {
	/*game[ "state" ] = "intermission";
	level notify( "intermission" );

	players = getEntArray( "player", "classname" );
	for( i = 0; i < players.size; i++ ) {
		players[i] closeMenu();
		players[i] closeInGameMenu();
		players[i] spawnIntermission();
	}*/

	surf\_vote::mapvote();
}

checkTimeLimit() {
	if( level.timelimit <= 0 )
		return;

	timepassed = ( getTime() - level.starttime ) / 1000;
	timepassed = timepassed / 60.0;
	level.timeLeft = level.timelimit - timepassed;
	
	if( isDefined( level.updateTimer ) && level.updateTimer ) {
		level.clock setTimer( level.timeLeft * 60 );
	}

	if( timepassed < level.timelimit )
		return;

	if( level.mapended )
		return;
	
	if( isDefined( level.clock ) )	
		level.clock destroy();
		
	level.mapended = true;
	level thread endMap();
}

setSpectatorPermissions() {
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "freelook", true );
	self allowSpectateTeam( "none", true );
}

setVelocityBase( velocity ) {
	if( !isDefined( self.baseVelocity ) )
		self.baseVelocity = ( 0, 0, 0 );
	if( !isDefined( self.baseVelocityLast ) )
		self.baseVelocityLast = 0;
	if( getTime() - self.baseVelocityLast > 100 )
		self.baseVelocity = ( 0, 0, 0 );
		
	velocity += self.baseVelocity;		
	
	self setVelocity( velocity );
}

allies() {
	self setTeam( "allies" );
}

axis() {
	self setTeam( "axis" );
}

spectator() {
	self setTeam( "spectator" );
}

setTeam( team ) {
	if( self.pers[ "team" ] == team )
		return;

	if( isAlive( self ) )
		self suicide();
	
	self.pers[ "team" ] = team;
	self.team = team;
	self.sessionteam = team;

	self setClientDvars( "g_scriptMainMenu", game[ "menu_ingame_main" ] );
}

getVelocityBase() {
	if( !isDefined( self.baseVelocity ) )
		self.baseVelocity = ( 0, 0, 0 );
	if( !isDefined( self.baseVelocityLast ) )
		self.baseVelocityLast = 0;
	if( getTime() - self.baseVelocityLast > 100 )
		self.baseVelocity = ( 0, 0, 0 );
	
	ret = self getVelocity();
	ret -= self.baseVelocity;
	
	return ret;
}

updateSpeedHud() {
	self endon( "disconnect" );
	self endon( "spawned" );

	for(;;) {
		self.speed = self getPlayerSpeed();
		self.speedHud setValue( self.speed );
		wait .1;
	}
}

updateStats() {
	self endon( "disconnect" );
	self endon( "spawned" );

	for(;;) {
		self.kills = self.speed; // We're tracking this in another place already and we don't need to update this as often
		self.assists = self getFps();
		wait .25;
	}
}

trail( fx ) {
	level endon( "intermission" );
	self endon( "disconnect" );
	self endon( "spawned" );
	
	for(;;) {
		wait .05;
		playFx( fx, self.origin );
	}
}