<?php

class RecordsController extends AppController {
	function __construct( $args ) {
		parent::__construct( $args );

		$this->template = 'Records/index';

		$maps = $this->app->DB->query( "SELECT DISTINCT map FROM surf_records ORDER BY map ASC" );
		$this->set( [ 'maps', $maps ] );

		if( isset( $args[0] ) && !strchr( $args[0], ';' ) ) {
			$this->set( [ 'selectedMap', $args[0] ] );
		} else {
			$args = array( $maps[0][ 'map' ] );
		}

		if( isset( $args[1] ) && is_numeric( $args[1] ) ) {
			$page = $args[1];
		} else {
			$page = 1;
		}
		$this->set( [ 'page', $page ] );

		if( !isset( $args[2] ) || $args[2] != 'all' ) {
			$records = $this->app->DB->query( "SELECT SQL_CALC_FOUND_ROWS any_value(id) AS id, min(maptime) AS maptime, any_value(player_id) AS player_id, any_value(map) AS map FROM surf_records WHERE map='" . $args[0] . "' GROUP BY player_id ORDER BY maptime ASC LIMIT " . ( ( $page - 1 ) * 25 ) . ", 25" );
			$this->set( [ 'unique', true ] );
		} else {
			$records = $this->app->DB->query( "SELECT SQL_CALC_FOUND_ROWS * FROM surf_records WHERE map='" . $args[0] . "' ORDER BY maptime ASC LIMIT " . ( ( $page - 1 ) * 25 ) . ", 25" );
			$this->set( [ 'unique', false ] );
		}
		
		$this->set( [ 'records', $records ] );
		$this->set( [ 'page_count', ceil( $this->app->DB->query( "SELECT FOUND_ROWS() AS row_count" )[0][ 'row_count' ] / 25 ) ] );

		$players = array();
		foreach( $records as $record ) {
			array_push( $players, $this->app->DB->query( "SELECT name FROM players WHERE id='" . $record[ 'player_id' ] . "'" )[0][ 'name' ] );
		}
		$this->set( [ 'players', $players ] );
	}
}
