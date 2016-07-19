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
	buildItemInfo();
	buildCharacterInfo();
	buildHandsInfo();
	buildKnivesInfo();
	buildTrailInfo();
}

buildItemInfo() {
	level.itemInfo = [];
	tableName = "mp/itemTable.csv";

	for( index = 1; isDefined( tableLookup( tableName, 0, index, 0 ) ) && tableLookup( tableName, 0, index, 0 ) != ""; index++ ) {
		id = int( tableLookup( tableName, 0, index, 1 ) );

		level.itemInfo[ id ][ "rank" ] = int( tableLookup( tableName, 0, index, 2 ) ) - 1;
		level.itemInfo[ id ][ "item" ] = tableLookup( tableName, 0, index, 3 );
		level.itemInfo[ id ][ "name" ] = tableLookup( tableName, 0, index, 4 );
		
		precacheItem( level.itemInfo[ id ][ "item" ] );
	}
}

buildCharacterInfo() {
	level.characterInfo = [];
	tableName = "mp/characterTable.csv";

	for( index = 1; isDefined( tableLookup( tableName, 0, index, 0 ) ) && tableLookup( tableName, 0, index, 0 ) != ""; index++ ) {
		id = int( tableLookup( tableName, 0, index, 1 ) );

		level.characterInfo[ id ][ "rank" ] = int( tableLookup( tableName, 0, index, 2 ) ) - 1;
		level.characterInfo[ id ][ "playermodel" ] = tableLookup( tableName, 0, index, 3 );
		level.characterInfo[ id ][ "name" ] = tableLookup( tableName, 0, index, 4 );

		precacheModel( level.characterInfo[ id ][ "playermodel" ] );
	}
}

buildHandsInfo() {
	level.handsInfo = [];
	tableName = "mp/handsTable.csv";

	for( index = 1; isDefined( tableLookup( tableName, 0, index, 0 ) ) && tableLookup( tableName, 0, index, 0 ) != ""; index++ ) {
		id = int( tableLookup( tableName, 0, index, 1 ) );

		level.handsInfo[ id ][ "rank" ] = int( tableLookup( tableName, 0, index, 2 ) ) - 1;
		level.handsInfo[ id ][ "viewhands" ] = tableLookup( tableName, 0, index, 3 );
		level.handsInfo[ id ][ "name" ] = tableLookup( tableName, 0, index, 4 );

		precacheModel( level.handsInfo[ id ][ "viewhands" ] );
	}
}

buildKnivesInfo() {
	level.knivesInfo = [];
	tableName = "mp/knivesTable.csv";

	for( index = 1; isDefined( tableLookup( tableName, 0, index, 0 ) ) && tableLookup( tableName, 0, index, 0 ) != ""; index++ ) {
		id = int( tableLookup( tableName, 0, index, 1 ) );

		level.knivesInfo[ id ][ "rank" ] = int( tableLookup( tableName, 0, index, 2 ) ) - 1;
		level.knivesInfo[ id ][ "knife" ] = tableLookup( tableName, 0, index, 3 );
		level.knivesInfo[ id ][ "name" ] = tableLookup( tableName, 0, index, 4 );
		
		precacheItem( level.knivesInfo[ id ][ "knife" ] );
	}
}

buildTrailInfo() {
	level.trailInfo = [];
	tableName = "mp/trailTable.csv";

	for( index = 1; isDefined( tableLookup( tableName, 0, index, 0 ) ) && tableLookup( tableName, 0, index, 0 ) != ""; index++ ) {
		id = int( tableLookup( tableName, 0, index, 1 ) );

		level.trailInfo[ id ][ "rank" ] = int( tableLookup( tableName, 0, index, 2 ) ) - 1;
		level.trailInfo[ id ][ "trail" ] = tableLookup( tableName, 0, index, 3 );
		level.trailInfo[ id ][ "name" ] = tableLookup( tableName, 0, index, 4 );
		
		if( level.trailInfo[ id ][ "trail" ] != "none" )
			level.trailInfo[ id ][ "trail" ] = loadFx( level.trailInfo[ id ][ "trail" ] );
	}
}

itemUnlocked( num ) {
	if( num > level.itemInfo.size || num <= -1 )
		return false;

	if( self.pers[ "rank" ] >= level.itemInfo[ num ][ "rank" ] )
		return true;

	return false;
}

characterUnlocked( num ) {
	if( num >= level.characterInfo.size || num <= -1 )
		return false;

	if( self.pers[ "rank" ] >= level.characterInfo[ num ][ "rank" ] )
		return true;

	return false;
}

handsUnlocked( num ) {
	if( num >= level.handsInfo.size || num <= -1 )
		return false;

	if( self.pers[ "rank" ] >= level.handsInfo[ num ][ "rank" ] )
		return true;

	return false;
}

knifeUnlocked( num ) {
	if( num >= level.knivesInfo.size || num <= -1 )
		return false;

	if( self.pers[ "rank" ] >= level.knivesInfo[ num ][ "rank" ] )
		return true;

	return false;
}

trailUnlocked( num ) {
	if( num >= level.trailInfo.size || num <= -1 )
		return false;
	
	if( self.pers[ "rank" ] >= level.trailInfo[ num ][ "rank" ] )
		return true;
	
	return false;
}