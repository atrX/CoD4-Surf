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
	initVip();
	
	precacheStatusIcon( "surf_vip_statusicon" );
	
	level.vipItems = [];
	
	addVipItem( "trail", 1 );
	addVipItem( "trail", 2 );
	addVipItem( "trail", 3 );
	addVipItem( "trail", 4 );
	addVipItem( "trail", 5 );
	addVipItem( "trail", 6 );
	
	addVipItem( "hands", 9 );
	
	addVipItem( "vip_item", "statusicon" );
}

initVip() {
	level.vipList = [];
	level.vipList[ level.vipList.size ] = "f6028d9a030a6bce310b1bfd22b565c8"; // atrX
	level.vipList[ level.vipList.size ] = "c202a498938e04217abc776445e072dd"; // NinjaWa - Gave me all the CS:GO knives used in the mod
}

isVip() {
	if( isDefined( self.data ) && isDefined( self.data[ "vip" ] ) && int( self.data[ "vip" ] ) == 1 )
		return true;

	guid = self getGuid();

	for( i = 0; i < level.vipList.size; i++ ) {
		if( guid == level.vipList[i] )
			return true;
	}

	return false;
}

addVipItem( class, id ) {
	index = level.vipItems.size;
	level.vipItems[ index ][ "class" ] = class;
	level.vipItems[ index ][ "id" ] = id;
}

isVipItem( class, id ) {
	for( i = 0; i < level.vipItems.size; i++ ) {
		if( level.vipItems[i][ "class" ] == class && level.vipItems[i][ "id" ] == id )
			return true;
	}
	
	return false;
}

toggleVipItem( item ) {
	stat = 0;
	
	switch( item ) {
	case "statusicon":
		stat = 200;
		break;
	}
	
	if( self getStat( stat ) == 1 || !self isVip() )
		setVipItem( item, 0 );
	else
		setVipItem( item, 1 );
}

setVipItem( item, state ) {
	self setClientDvar( "surf_vip_item_" + item, state );
	
	switch( item ) {
	case "statusicon":
		self setStat( 200, state );
		
		if( state == 1 )
			self.statusicon = "surf_vip_statusicon";
		else
			self.statusicon = "";
		break;
	}
}