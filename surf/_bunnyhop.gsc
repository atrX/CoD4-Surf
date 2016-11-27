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

bunnyhop() {
	self endon( "disconnect" );
	self endon( "spawned" );

	hopHeight = sqrt( 40 * getDvarInt( "g_gravity" ) );

	for(;;) {
		wait .05;

		if( self.isSurfing )
			continue;

		if( isDefined( self ) && isAlive( self ) ) {
			playerVel = self getVelocity();
			playerSpeed = sqrt( ( playerVel[0] * playerVel[0] ) + ( playerVel[1] * playerVel[1] ) );

			if( playerSpeed < 300 ) {
				playerSpeed = 300;
				playerVel = vectorScale( vectorNormalize( playerVel ), playerSpeed );
			}
			
			if( self inNoHopZone() && playerSpeed > 320 ) {
				playerSpeed = 280;
				playerVel = vectorScale( vectorNormalize( playerVel ), playerSpeed );
			}

			if( ( self jumpButtonPressed() || ( self.autoHop && self surf\_util::getPlayerSpeed() > 0 ) ) && ( self isOnGround() || self.wasOnGroundLastTime ) ) {
				playerSpeedLastTime = sqrt( ( self.velLastTime[0] * self.velLastTime[0] ) + ( self.velLastTime[1] * self.velLastTime[1] ) );
				
				if( playerSpeedLastTime > playerSpeed ) {
					playerVel = ( playerVel[0] * playerSpeedLastTime / playerSpeed, playerVel[1] * playerSpeedLastTime / playerSpeed, playerVel[2] );
					playerSpeed = playerSpeedLastTime;
				}

				if( !self.wasOnGroundLastTime && playerSpeed < 600 * 1.6 ) {
					playerVel = ( 1.2 * playerVel[0], 1.2 * playerVel[1], playerVel[2] );
					playerSpeed *= 1.2;
				}

				playerVel = ( playerVel[0], playerVel[1], hopHeight );
				self setVelocity( playerVel );
			}

			if( self.autoHop )
				self.wasInJumpLastTime = true;
			else
				self.wasInJumpLastTime = self jumpButtonPressed();
			self.wasOnGroundLastTime = self isOnGround();
			self.velLastTime = playerVel;
		}
	}
}

inNoHopZone() {
	noHopZones = getEntArray( "trigger_nohop", "targetname" );
	for( i = 0; i < noHopZones.size; i++ ) {
		if( self isTouching( noHopZones[i] ) )
			return true;
	}
	
	return false;
}