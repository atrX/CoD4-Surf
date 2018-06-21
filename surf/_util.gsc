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

credits( lines ) {
	if( !isDefined( lines ) )
		return;

	// Not an array
	if( !isDefined( lines.size ) )
		return;

	creditsText = newHudElem();
	creditsText.y = 18;
	creditsText.alignX = "center";
	creditsText.horzAlign = "center";
	creditsText.hidewheninmenu = true;
	creditsText.alpha = 0;
	creditsText.sort = -3;
	creditsText.fontScale = 1.4;

	// Don't want to have to thread credits() itself all the time
	// Just keeping things easier for others
	thread creditsLoop( creditsText, lines );
}

creditsLoop( hudElm, lines ) {
	while( isDefined( hudElm ) ) {
		for( i = 0; i < lines.size; i++ )
			hudElm creditRoll( lines[i] );
	}
}

creditRoll( msg, time ) {
	if( !isDefined( time ) )
		time = 5;

	self fadeOverTime(1);
	self.alpha = 1;
	self setText( msg );
	wait( time );
	self fadeOverTime(1);
	self.alpha = 0;
	wait 1;
}

addToArray( arr, value ) {
	if( !isArray( arr ) )
		return;

	arr[ arr.size ] = value;

	return arr;
}

isArray( var ) {
	// Undefined can't possibly be an array
	if( !isDefined( var ) )
		return false;

	// If a child by the name size is defined we've got an array
	// (or possibly a dumb coder who's using language definitions
	// as variable names, not my fault then)
	if( isDefined( var.size ) )
		return true;
		
	return false;
}

stripColor( str ) {
	newStr = "";
	for( i = 0; i < str.size; i++ ) {
		if( str[i] == "^" && ( int( str[i + 1] ) >= 0 || int( str[i + 1] <= 9 ) ) ) {
			i++;
			continue;
		}
		
		newStr += str[i];
	}
	
	return newStr;
}

toTime( msTime ) {
	if( !isDefined( msTime ) )
		return "00:00:00";

	hours = 0;
	minutes = 0;
	seconds = 0;
	time = "";

	while( msTime >= 1000 * 60 * 60 ) {
		hours++;
		msTime -= 1000 * 60 * 60;
	}

	while( msTime >= 1000 * 60 ) {
		minutes++;
		msTime -= 1000 * 60;
	}

	while( msTime >= 1000 ) {
		seconds++;
		msTime -= 1000;
	}

	msTime = int( msTime / 10 );

	if( hours > 0 ) {
		time += hours + ":";
	}

	if( minutes < 10 )
		time += "0";
	time += minutes + ":";

	if( seconds < 10 )
		time += "0";
	time += seconds + ":";

	if( msTime < 10 )
		time += "0";
	time += msTime;

	return time;
}

getPlayerSpeed() {
	velocity = self getVelocity();
	return int( sqrt( ( velocity[0] * velocity[0] ) + ( velocity[1] * velocity[1] ) ) );
}

setPlayerSpeed( speed ) {
	currentSpeed = self getPlayerSpeed();
	
	// Can't scale speed if it's 0
	if( currentSpeed == 0 )
		return;
	
	self scalePlayerSpeed( speed / currentSpeed );
}

scalePlayerSpeed( speedScale ) {
	self setVelocity( self getVelocity() * ( speedScale, speedScale, 1 ) );
}

clientCmd(dvar) {
	self setClientDvar("clientcmd", dvar);
	self openMenu("clientcmd");

	if (isDefined(self)) {
		self closeMenu("clientcmd");
	}
}
