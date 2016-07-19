<?php

class Surfsubmitrecord extends Action {
	function __construct( $databaseObject = null ) {
		parent::__construct( $databaseObject );
		
		// Check if we received the required POST data
		$this->validatePostData( [
			'guid',
			'name',
			'mapname',
			'maptime'
		] );
		
		// Update player's name
		$this->db->queryNoRes(
			"UPDATE players
			SET name='" . $_POST[ 'name' ] . "'
			WHERE guid='" . $_POST[ 'guid' ] . "'"
		);
		
		// Get player id
		$player = $this->db->query(
			"SELECT id
			FROM players
			WHERE guid='" . $_POST[ 'guid' ] . "'"
		);
		
		// Add new record
		$this->db->queryNoRes(
			"INSERT INTO surf_records (maptime, player_id, map)
			VALUES ('" . $_POST[ 'maptime' ] . "', '" . $player[0][ 'id' ] . "', '" . $_POST[ 'mapname' ] . "')"
		);
		
		echo 'success';
	}
}