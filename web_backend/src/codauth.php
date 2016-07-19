<?php

class Codauth extends Action {
	function __construct( $databaseObject = null ) {
		parent::__construct( $databaseObject );
		
		// Check if we received the required POST data
		$this->validatePostData( [
			'ip',
			'guid',
			'b3cid',
			'level'
		] );
		
		$ipb = new DB();
		$ipb->connect( 'revmods_forums' );
		
		$members = $ipb->query(
			"SELECT member_id
			FROM ipb_core_sessions
			WHERE ip_address='" . $_POST[ 'ip' ] . "'"
		);
		
		foreach( $members as $member ) {
			$data = $ipb->query(
				"SELECT field_19 AS guid, field_20 AS b3cid, field_21 AS level
				FROM ipb_core_pfields_content
				WHERE member_id='" . $member[ 'member_id' ] . "'"
			)[0];
			
			if( $data[ 'guid' ] == $_POST[ 'guid' ] && $data[ 'b3cid' ] == $_POST[ 'b3cid' ] && $data[ 'level' ] == $_POST[ 'level' ] ) {
				die( '1' );
			}
		}
		
		echo 'No match.';
	}
}