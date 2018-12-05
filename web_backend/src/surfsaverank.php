<?php

class Surfsaverank extends Action {
	function __construct( $databaseObject = null ) {
		parent::__construct( $databaseObject );
		
		// Check if we received the required POST data
		$this->validatePostData( [
			'guid',
			'name',
			'rank',
			'rankxp'
		] );
		
		// Update stats
		$this->db->queryNoRes(
			"UPDATE players
			SET name='" . str_replace("'", "\'", $_POST[ 'name' ]) . "', rankxp_surf='" . $_POST[ 'rankxp' ] . "', rank_surf='" . $_POST[ 'rank' ] . "'
			WHERE guid='" . $_POST[ 'guid' ] . "'"
		);
		
		echo 'success';
	}
}