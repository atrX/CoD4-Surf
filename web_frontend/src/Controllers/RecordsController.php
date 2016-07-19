<?php

class RecordsController extends AppController {
	function __construct( $args ) {
		parent::__construct( $args );

		$this->template = 'Records/index';

		$maps = $this->app->DB->query( "SELECT DISTINCT map FROM surf_records ORDER BY map ASC" );
		$this->set( [ 'maps', $maps ] );

		if( isset( $args[0] ) ) {
			$this->set( [ 'selectedMap', $args[0] ] );
		} else {
			$args = array( $maps[0][ 'map' ] );
		}

		if( !isset( $args[1] ) || $args[1] != 'all' ) {
			$records = $this->app->DB->query( "SELECT id, MIN(maptime) AS maptime, player_id, map FROM surf_records WHERE map='" . $args[0] . "' GROUP BY player_id ORDER BY maptime ASC" );
		} else {
			$records = $this->app->DB->query( "SELECT * FROM surf_records WHERE map='" . $args[0] . "' ORDER BY maptime ASC" );
		}
		
		$this->set( [ 'records', $records ] );

		$players = array();
		foreach( $records as $record ) {
			array_push( $players, $this->app->DB->query( "SELECT name FROM players WHERE id='" . $record[ 'player_id' ] . "'" )[0][ 'name' ] );
		}
		$this->set( [ 'players', $players ] );
	}
}
