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

surf() {
	self endon( "disconnect" );
	self endon( "spawned" );
	
	self.isSurfing = false;
	
	self thread stopAirStrafe();

	for(;;) {
		wait .05;

		if( !self isOnRamp() ) {
			self.isSurfing = false;
			self airStrafe();
			continue;
		}
		
		if( self backwardButtonPressed() ) {
			self.isSurfing = false;
			self setVelocity( self getVelocity() * ( 0, 0, 1 ) );
			continue;
		}
		
		if( self forwardButtonPressed() ) {
			self.isSurfing = false;
			continue;
		}

		self.isSurfing = true;
		self airStrafe();
	}
}

isOnRamp() {
	if( self isOnRampLeft() || self isOnRampRight() )
		return true;

	return false;
}

isOnRampLeft() {
	dist = physicsTrace(
		self.origin,
		self.origin + vectorScale(
			anglesToRight( self getPlayerAngles() ),
			-25
		)
	);
	
	if( distanceSquared( dist, self.origin ) < 256 )
		return true;
		
	return false;
}

isOnRampRight() {
	dist = physicsTrace(
		self.origin,
		self.origin + vectorScale(
			anglesToRight( self getPlayerAngles() ),
			25
		)
	);
	
	if( distanceSquared( dist, self.origin ) < 256 )
		return true;
		
	return false;
}

airStrafe() {
	dot = vectorDot(
		anglesToForward( ( 0, self getPlayerAngles()[1], 0 ) ),
		vectorNormalize( self getVelocity() )
	) + .01;

	velMatchingDir = 1;
	if( dot < 0 )
		velMatchingDir = -1;

	if( self isOnGround() || ( !( self leftButtonPressed() || self rightButtonPressed() ) && !self.autoSurf ) )
		return;
	
	vel = self getVelocity();
	newVel = vectorScale( 
		anglesToForward( ( 0, self getPlayerAngles()[1], 0 ) ),
		length( ( vel[0], vel[1], 0 ) )
	);
	self setVelocity( ( newVel[0] * velMatchingDir, newVel[1] * velMatchingDir, vel[2] ) );
}

stopAirStrafe() {
	self endon( "disconnect" );
	self endon( "spawned_player" );
	
	for(;;) {
		airTime = 0;
		
		while( self isOnGround() ) {
			wait .05;
		}
		
		while( ( !isDefined( self.isSurfing ) || !self.isSurfing ) && airTime < 1.5 ) {
			if( self isOnGround() )
				airTime = 0;
			else
				airTime += .05;
				
			wait .05;
		}
			
		// At this point we've been on a surf or been in the air for long enough
		while( !self isOnGround() || self.isSurfing ) {
			if( self backwardButtonPressed() )
				self setVelocity( self getVelocity() * ( 0, 0, 1 ) );
			wait .05;
		}
		
		wait .05;
	}
}