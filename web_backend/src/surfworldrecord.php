<?php

class Surfworldrecord extends Action {
	function __construct( $databaseObject = null ) {
		parent::__construct( $databaseObject );
		
		// Check if we received the required POST data
		$this->validatePostData( [
			'mapname'
		] );
		
		$record = $this->db->query(
			"SELECT maptime, player_id
			FROM surf_records
			WHERE map='" . $_POST[ 'mapname' ] . "'
			ORDER BY maptime ASC"
		);
		
		if( count( $record ) > 0 && $record[0][ 'maptime' ] != '' ) {
			$player = $this->db->query(
				"SELECT name
				FROM players
				WHERE id='" . $record[0][ 'player_id' ] . "'"
			);
	
			echo $player[0][ 'name' ] . ';' . $record[0][ 'maptime' ];
		} else {
			echo '0;0';
		}
	}
}