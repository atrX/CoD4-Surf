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

// This file will need to be updated every time we add a new map unfortunately :/

getDifficulty( mapname  ) {
	switch( mapname ) {
	case "mp_surf_beginner":
	case "mp_surf_aircontrol":
	case "mp_surf_rebel":
	case "mp_surf_utopia":
	case "mp_surf_space":
	case "mp_surf_cyber":
	case "mp_surf_kitsune":
	case "mp_surf_mesa":
		return "easy";
		
	case "mp_surf_airarena":
	case "mp_surf_neonrider":
		return "intermediate";
	
	case "some_hard_map":
		return "hard";
		
	default:
		return undefined;
	}
}