<?php

class Surfauth extends Action {
	function __construct( $databaseObject = null ) {
		parent::__construct( $databaseObject );
		
		// Check if we received the required POST data
		$this->validatePostData( [
			'guid',
			'name',
			'mapname'
		] );
		
		$playerData = $this->db->query(
			"SELECT id, vip, vip_expiry, rankxp_surf
			FROM players
			WHERE guid='" . $_POST[ 'guid' ] . "'"
		);
		
		if( count( $playerData ) < 1 ) {
			$this->db->queryNoRes(
				"INSERT INTO players (guid, name, vip, vip_expiry, rank_surf, rankxp_surf)
				VALUES ('" . $_POST[ 'guid' ] . "', '" . $_POST[ 'name' ] . "', '0', '', '1', '0')"
			);
			
			echo 'vip:0;record:0;rankxp:0';
		} else {
			// Take VIP away if it has expired
			if( $playerData[0][ 'vip' ] == 1 && $playerData[0][ 'vip_expiry' ] != '' && strtotime( 'now' ) > strtotime( $playerData[0][ 'vip_expiry' ] ) ) {
				$this->db->queryNoRes(
					"UPDATE players
					SET vip='0'
					WHERE guid='" . $_POST[ 'guid' ] . "'"
				);
			}
			
			// Update player's name
			$this->db->queryNoRes(
				"UPDATE players
				SET name='" . $_POST[ 'name' ] . "'
				WHERE guid='" . $_POST[ 'guid' ] . "'"
			);
			
			// Fetch personal best
			$record = $this->db->query(
				"SELECT MIN(maptime) AS record
				FROM surf_records
				WHERE player_id='" . $playerData[0][ 'id' ] . "' AND map='" . $_POST[ 'mapname' ] . "'"
			);
			
			echo 'vip:' . $playerData[0][ 'vip' ] .
			';record:' . ( count( $record ) > 0 && $record[0][ 'record' ] != '' ? $record[0][ 'record' ] : '0' ) .
			';rankxp:' . $playerData[0][ 'rankxp_surf' ];
		}
	}
}