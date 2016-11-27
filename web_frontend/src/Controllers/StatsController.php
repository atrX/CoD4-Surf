<?php

class StatsController extends AppController {
	function __construct( $args ) {
		parent::__construct( $args );

		$this->template = 'Stats/index';

		if( isset( $args[0] ) && is_numeric( $args[0] ) ) {
			$cid = $args[0];
			$this->set( [ 'cid', $cid ] );

			$b3 = new Database( SQL_USER_B3, SQL_PASS_B3, SQL_DB_B3 );

			$guid = $b3->query( "SELECT guid FROM clients WHERE id='" . $cid . "'" );
			if( count( $guid ) > 0 ) {
				$guid = $guid[0][ 'guid' ];

				$player = $this->app->DB->query( "SELECT * FROM players WHERE guid='" . $guid . "'" );
				if( count( $player ) > 0 ) {
					$player = $player[0];
					$this->set( [ 'player', $player ] );

					$maps = $this->app->DB->query( "SELECT DISTINCT map FROM surf_records" );
					asort( $maps );

					$records = array();
					foreach( $maps as $map ) {
						$newRecord = $this->app->DB->query(
							"SELECT any_value(id) AS id, min(maptime) AS maptime, any_value(player_id) AS player_id, any_value(map) AS map
							FROM surf_records WHERE player_id='" . $player[ 'id' ] . "' AND map='" . $map[ 'map' ] . "'
							GROUP BY map
							ORDER BY maptime ASC"
						);
						
						if( count( $newRecord ) > 0 ) {
							array_push( $records, $newRecord[0] );
						}
					}

					$this->set( [ 'records', $records ] );
				}
			}
		}
	}
}
