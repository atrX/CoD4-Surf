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
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	level.callbackStartGameType 	= ::Callback_StartGameType;
	level.callbackPlayerConnect 	= ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect 	= ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage 		= ::Callback_PlayerDamage;
	level.callbackPlayerKilled 		= ::Callback_PlayerKilled;

	level.script 	= toLower( getDvar( "mapname" ) );
	level.gametype 	= toLower( getDvar( "g_gametype" ) );

	level.allies 	= ::allies;
	level.axis 		= ::axis;
	level.spectator = ::spectator;
}

Callback_StartGameType() {
	surf\_mod::main();
}

Callback_PlayerConnect() {
	self surf\_mod::Callback_PlayerConnect();
}

Callback_PlayerDisconnect() {
	self surf\_mod::Callback_PlayerDisconnect();
}

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime ) {
	// There's no reason we should ever take damage, this is not surf dm
	return;
}

Callback_PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration ) {
	// Can't deal damage, let alone kill someone
	return;
}

allies() {
	self surf\_mod::allies();
}

axis() {
	self surf\_mod::axis();
}

spectator() {
	self surf\_mod::spectator();
}