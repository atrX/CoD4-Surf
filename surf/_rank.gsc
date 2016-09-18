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

main() {
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PROMOTED" );
	precacheString( &"MP_PLUS" );

	level.rankTable = [];

	level.maxRank = int( tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ) );

	rankId = 0;
	rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );

	while( isDefined( rankName ) && rankName != "" ) {
		level.rankTable[ rankId ][ 1 ] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[ rankId ][ 2 ] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[ rankId ][ 3 ] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[ rankId ][ 7 ] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );
		precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rankId, 1 ) );

		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	}

	level thread onPlayerSpawned();
}

onPlayerSpawned() {
	for(;;) {
		level waittill( "player_spawn", player );

		if( !isDefined( player.hud_rankscroreupdate ) ) {
			player.hud_rankscroreupdate = newClientHudElem( player );
			player.hud_rankscroreupdate.horzAlign = "center";
			player.hud_rankscroreupdate.vertAlign = "middle";
			player.hud_rankscroreupdate.alignX = "center";
			player.hud_rankscroreupdate.alignY = "middle";
	 		player.hud_rankscroreupdate.x = 0;
			player.hud_rankscroreupdate.y = -60;
			player.hud_rankscroreupdate.font = "default";
			player.hud_rankscroreupdate.fontscale = 2.0;
			player.hud_rankscroreupdate.archived = false;
			player.hud_rankscroreupdate.color = ( .5, .5, .5 );
			player.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
		}

		player thread removeRankHUD();
		player thread proceduralXp();
	}
}

removeRankHUD() {
	if( isDefined( self.hud_rankscroreupdate ) )
		self.hud_rankscroreupdate.alpha = 0;
}

getRankForXp( xpVal ) {
	rankId = 0;
	rankName = level.rankTable[ rankId ][ 1 ];

	while ( isDefined( rankName ) && rankName != "" ) {
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;

		rankId++;

		if ( isDefined( level.rankTable[ rankId ] ) )
			rankName = level.rankTable[ rankId ][ 1 ];
		else
			rankName = undefined;
	}

	rankId--;
	return rankId;
}

getRankInfoMinXP( rankId ) {
	return int( level.rankTable[ rankId ][ 2 ] );
}

getRankInfoXPAmt( rankId ) {
	return int( level.rankTable[ rankId ][ 3 ] );
}

giveRankXP( amount ) {
	self endon( "disconnect" );

	if( getDvar( "dedicated" ) == "listen server" )
		return;
		
	if( self surf\_vip::isVip() )
		amount *= 2;
	
	if( level.dvar[ "xp_events" ] && isDefined( level.xpEventActive ) && level.xpEventActive )
		amount *= 2;
	
	self incRankXP( amount * level.dvar[ "xp_multiplier" ] );
	//self thread updateRankScoreHUD( amount );
}

updateRankScoreHUD( amount ) {
	if( amount == 0 )
		return;

	if( !isDefined( self.rankUpdateTotal ) )
		self.rankUpdateTotal = 0;

	self.rankUpdateTotal += amount;

	wait .05;

	if( isDefined( self.hud_rankscroreupdate ) ) {
		if( self.rankUpdateTotal < 0 ) {
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = ( 1, 0, 0 );
		} else {
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = ( 1, 1, .5 );
		}

		self.hud_rankscroreupdate setValue( self.rankUpdateTotal );
		self.hud_rankscroreupdate.alpha = .85;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 1;
		self.hud_rankscroreupdate fadeOverTime( .75 );
		self.hud_rankscroreupdate.alpha = 0;

		self.rankUpdateTotal = 0;
	}
}

updateRankAnnounceHUD() {
	newRankName = self getRankInfoFull( self.pers[ "rank" ] );

	notifyData = spawnStruct();
	notifyData.titleText = &"RANK_PROMOTED";
	notifyData.iconName = self getRankInfoIcon( self.pers[ "rank" ] );
	notifyData.sound = "mp_level_up";
	notifyData.duration = 4.0;
	notifyData.notifyText = newRankName;

	thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

	iPrintLn( &"RANK_PLAYER_WAS_PROMOTED", self, newRankName );
}

incRankXP( amount ) {
	xp = self getRankXP();
	newXp = xp + amount;

	if( self.pers[ "rank" ] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers[ "rankxp" ] = newXp;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );

	rankId = self getRankForXp( self getRankXP() );
	self updateRank( rankId );
}

getRankXP() {
	return self.pers[ "rankxp" ];
}

getRankInfoMaxXp( rankId ) {
	return int( level.rankTable[ rankId ][ 7 ] );
}

getRankInfoIcon( rankId ) {
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, 1 );
}

getRankInfoFull( rankId ) {
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}

updateRank( rankId ) {
	if( getRankInfoMaxXP( self.pers[ "rank" ] ) <= self getRankXP() && self.pers[ "rank" ] < level.maxRank ) {
		rankId = self getRankForXp( self getRankXP() );
		self setRank( rankId, 0 );
		self.pers[ "rank" ] = rankId;
		self updateRankAnnounceHUD();
	}
	updateRankStats( self, rankId );
}

updateRankStats( player, rankId ) {
	player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
	player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
	player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
}

proceduralXp() {
	self endon( "disconnect" );
	self endon( "spawned" );

	for(;;) {
		self.oldOrg = self.origin;
		wait 60;
		if( self.origin != self.oldOrg ) // We're not AFK
			self giveRankXP( 3 );
	}
}