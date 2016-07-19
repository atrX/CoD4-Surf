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
		player thread trackB3();
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