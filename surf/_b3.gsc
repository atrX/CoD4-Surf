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
	thread onPlayerConnect();
}

onPlayerConnect() {
	level endon( "game_ended" );

	for(;;) {
		level waittill( "connected", player );
		
		thread b3();
		player thread trackB3();
	}
}

b3() {
	for(;;) {
		if( getDvar( "surf_setrank_id" ) != "" ) {
			player = getEntByNum( getDvarInt( "surf_setrank_id" ) );
			rankId = getDvarInt( "surf_setrank_rank" ) - 1;
			
			if( player.pers[ "rank" ] > rankId ) {
				// Reset stuff
			}
			
			newXp = surf\_rank::getRankInfoMinXP( rankId );
			
			if( newXp >= surf\_rank::getRankInfoMaxXP( level.maxRank ) )
				newXp = surf\_rank::getRankInfoMaxXP( level.maxRank );
		
			player.pers[ "rankxp" ] = newXp;
			player maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );
		
			rankId = player surf\_rank::getRankForXp( newXp );
			player.pers[ "rank" ] = rankId;
			player setStat( 252, rankId );
			player setRank( rankId );

			httpPostRequestAsync(
				level.dvar[ "surf_api_host" ],
				80,
				"sys/cod4/backend.php?action=surfsaverank",
				"apikey=" + level.dvar[ "surf_api_key" ] +
				"&guid=" + player getGuid() +
				"&name=" + surf\_util::stripColor( player.name ) +
				"&rankxp=" + newXp +
				"&rank=" + ( rankId + 1 )
			);
			
			setDvar( "surf_setrank_id", "" );
			setDvar( "surf_setrank_rank", "" );
		}
		
		if( getDvarInt( "surf_extend_timer" ) == 1 ) {
			thread surf\_vote::extendTimer();
			
			setDvar( "surf_extend_timer", 0 );
		}
		
		wait .1;
	}
}

trackB3() {
	self endon( "disconnect" );

	clientId = self getEntityNumber();

	for(;;) {
		if( getDvarInt( "surf_respawn_" + clientId ) == 1 ) {
			setDvar( "surf_respawn_" + clientId, 0 );
			
			if( isDefined( self.sessionstate ) && self.sessionstate == "playing" )
				self thread surf\_mod::respawn();
			else
				self iPrintLn( "^7You have to be alive to respawn!" );
		}

		wait .1;
	}
}