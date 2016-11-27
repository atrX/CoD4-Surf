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
	   
	   player.challengesDisabled = player getStat( 910 );
	   player.inChallenge = false;
   }
}

challenge( challengerId, challengedId ) {
	challenger = getEntByNum( challengerId );
	challenged = getEntByNum( challengedId );
	
	// Check if we can start a challenge request
	if( challenger == challenged ) {
        challenger iPrintLn( "You cannot challenge yourself!" );
        return;
    }
    
	if( challenger.inChallenge ) {
		challenger iPrintLn( "You are already participating in a challenge!" );
		return;
	}
	
	if( challenged.inChallenge ) {
		challenger iPrintLn( challenged.name + " ^7is already participating in a challenge!" );
		return;
	}
	
	if( challenged.challengesDisabled ) {
		challenger iPrintLn( challenged.name + " ^7has disabled challenges!" );
		return;
	}
	
	// Make a challenge request
	/*
	Possible return codes:
	false: declined
	true: accepted
	undefined: timed out
	 */
	accepted = challengeRequest( challenger, challenged );
	
	if( !isDefined( accepted ) ) {
		challenger iPrintLn( challenged.name + " ^7did not reply to your challenge request in time" );
		return;
	}
	
	if( !accepted ) {
		challenger iPrintLn( challenged.name + " ^7has declined your challenge request" );
		return;
	}
	
	// Set up the challenge
	challenger.inChallenge = true;
	challenged.inChallenge = true;
	challenger iPrintLnBold( "Starting challenge VS " + challenged.name );
	challenged iPrintLnBold( "Starting challenge VS " + challenger.name );
	
	wait 1.5;
	
	notification = "challenge_" + challengerId + "_" + challengedId + "_ended";
    spawnpoints = getEntArray( "mp_dm_spawn", "classname" );
	spawnpoint = spawnpoints[ randomInt( spawnpoints.size ) ];
	challenger thread startChallenge( challenged, notification, spawnpoint );
	challenged thread startChallenge( challenger, notification, spawnpoint );
	
	// Wait for challenge to end
	level waittill( notification, winner, loser );
	
	iPrintLn( winner.name + " ^7won a challenge against " + loser.name + "^7!" );
	winner surf\_rank::giveRankXP( level.dvar[ "surf_challenge_xp_reward" ] );
	
	winner.inChallenge = false;
	loser.inChallenge = false;
}

challengeRequest( challenger, challenged ) {
	self endon( "disconnect" );
	challenged endon( "challenge_request_timeout" );
	
	challenged thread challengeTimeout();
	challenged iPrintLn( "You have been challenged by " + challenger.name );
	wait 1;
	challenged openMenu( "challenge_request" );
	
	for(;;) {
		challenged waittill( "menuresponse", menu, response );
		
		if( menu == "challenge_request" ) {
			if( int( response ) == 1 ) {
				return true;
			} else {
				return false;
			}
			
			self notify( "challenge_request_replied" );
		}
	}
}

challengeTimeout() {
	self endon( "challenge_request_replied" );
	wait level.dvar[ "surf_challenge_request_time" ];
	self notify( "challenge_request_timeout" );
    self closeIngameMenu();
    self closeMenu();
}

startChallenge( opponent, notification, spawnpoint ) {
    if( isDefined( self.clock ) )
        self.clock destroy();
    
	self thread endChallengeOnDisconnect( notification, opponent );
	self thread endChallengeOnSpectator( notification, opponent );
	self endon( notification );
	
	self surf\_mod::spawnPlayer();
	self freezeControls( true );
    self setOrigin( spawnpoint.origin );
    self setPlayerAngles( spawnpoint.angles );
	
	countdownTime = level.dvar[ "surf_challenge_countdown_time" ];
	
	self.challengeCountdown = newClientHudElem( self );
	self.challengeCountdown.alpha = 0;
	self.challengeCountdown.x = 0;
	self.challengeCountdown.y = 0;
	self.challengeCountdown.alignX = "center";
	self.challengeCountdown.alignY = "middle";
	self.challengeCountdown.horzAlign = "center";
	self.challengeCountdown.vertAlign = "middle";
	self.challengeCountdown.font = "default";
	self.challengeCountdown.fontscale = 1.8;
	self.challengeCountdown.hidewheninmenu = false;
	
	self.challengeCountdown setValue( countdownTime );
	
	self.challengeCountdown fadeOverTime( .15 );
	self.challengeCountdown.alpha = 1;
	
	while( countdownTime > 1 ) {
		countdownTime--;
		
		self.challengeCountdown fadeOverTime( .15 );
		self.challengeCountdown.alpha = 0;
		
		wait .15;
		self.challengeCountdown setValue( countdownTime );
		
		self.challengeCountdown fadeOverTime( .15 );
		self.challengeCountdown.alpha = 1;
		wait .85;
	}
	
	self.challengeCountdown fadeOverTime( .15 );
	self.challengeCountdown.alpha = 0;
	
	wait .15;
	self.challengeCountdown setText( "GO!" );
	self freezeControls( false );
    
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

    self thread surf\_records::endmapTrigger();
	
	self.challengeCountdown fadeOverTime( .15 );
	self.challengeCountdown.alpha = 1;
	
	wait 1;
	self.challengeCountdown fadeOverTime( .15 );
	self.challengeCountdown.alpha = 0;
	wait .2;
	self.challengeCountdown destroy();
	
	self waittill( "map_finished" );
	level notify( notification, self, opponent );
}

endChallengeOnDisconnect( notification, opponent ) {
	level endon( notification );
	self waittill( "disconnect" );
	level notify( notification, opponent, self );
}

endChallengeOnSpectator( notification, opponent ) {
	level endon( notification );
	self waittill( "spectator_spawn" );
	level notify( notification, opponent, self );
}