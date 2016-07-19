<?php

class Action {
	protected $db;

	function __construct( $databaseObject ) {
		$this->db = $databaseObject;
	}
	
	function validatePostData( $data ) {
		for( $i = 0; $i < count( $data ); $i++ ) {
			if( !isset( $_POST[ $data[ $i ] ] ) ) {
				die( 'Error: ' . $data[ $i ] . ' not set.' );
			}
		}
	}
}