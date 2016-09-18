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
	thread onSpectate();
	thread onSpawn();
}

onSpectate() {
	for(;;) {
		level waittill( "spectator_spawn", player );
		player thread trackSpectatorClientInput();
	}
}

trackSpectatorClientInput() {
	self endon( "disconnect" );
	self endon( "spawned" );

	for(;;) {
		if( self getSpectatedClient() > -1 ) {
			client = getEntByNum( self getSpectatedClient() );
			self setClientDvar( "spectator_hud_auto_surf", client.autoSurf );
			self setClientDvar( "spectator_hud_input_fwd", client forwardButtonPressed() );
			self setClientDvar( "spectator_hud_input_bck", client backButtonPressed() );
			self setClientDvar( "spectator_hud_input_lft", client leftButtonPressed() );
			self setClientDvar( "spectator_hud_input_rght", client rightButtonPressed() );
			self setClientDvar( "spectator_hud_input_jmp", client jumpButtonPressed() );
		}

		wait .1;
	}
}

onSpawn() {
	for(;;) {
		level waittill( "player_spawn", player );
		
		player thread spectatorList();
	}
}

spectatorList() {
	self endon( "disconnect" );
	self endon( "spawned" );
	
	for(;;) {
		self.spectators = [];
		
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ ) {
			if( self getEntityNumber() == players[i] getSpectatedClient() )
				self.spectators[ self.spectators.size ] = players[i].name;
		}
		
		if( self.spectators.size > 0 && self getStat( 987 ) == 0 ) {
			if( !isDefined( self.spectatorList ) ) {
				self.spectatorList = newClientHudElem( self );
				self.spectatorList.horzAlign = "left";
				self.spectatorList.vertAlign = "middle";
				self.spectatorList.alignX = "left";
				self.spectatorList.alignY = "middle";
				self.spectatorList.x = 12;
				self.spectatorList.y = 0;
				self.spectatorList.font = "default";
				self.spectatorList.fontscale = 1.4;
				self.spectatorList.hidewheninmenu = true;
			}
			
			spectatorString = "";
			
			for( i = 0; i < self.spectators.size; i++ ) {
				spectatorString += self.spectators[i];
				
				if( i < self.spectators.size - 1 )
					spectatorString += "\n^7";
			}
			
			self.spectatorList setText( "^7Spectators:\n" + spectatorString );
		} else if( isDefined( self.spectatorList ) )
			self.spectatorList destroy();
		
		wait 1;
	}
}