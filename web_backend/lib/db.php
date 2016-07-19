<?php

class DB {
	private $conn;

	function __construct() {
		$this->conn = null;
	}
	
	function connect( $dbname ) {
		$this->conn = null;
		
		try {
			$this->conn = new PDO(
				'mysql:host=' . SQL_HOST . ';dbname=' . $dbname,
				SQL_USER,
				SQL_PASS
			);

			$this->conn->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
		} catch( PDOException $e ) {
			$this->logWrite( $e->getMessage() );
			die( 'Connection to database could not be established.' );
		}
	}

	function __destruct() {
		$conn = null;
	}
	
	/**
	 * query()
	 * Executes an SQL query and returns the array of fetched results
	 * params:
	 * 	0: $str (string)
	 */
	function query( $str ) {
		try {
			$stmt = $this->conn->prepare( $str );
			$stmt->execute();
			$stmt->setFetchMode( PDO::FETCH_ASSOC );

			return $stmt->fetchAll();
		} catch( PDOException $e ) {
			$this->logWrite( $e->getMessage() );
			die( 'Database query failed.' );
		}
	}
	
	/**
	 * queryNoRes()
	 * Executes an SQL query without fetching a result
	 * params:
	 * 	0: $str (string)
	 */
	function queryNoRes( $str ) {
		try {
			$stmt = $this->conn->prepare( $str );
			$stmt->execute();
		} catch( PDOException $e ) {
			$this->logWrite( $e->getMessage() );
			die( 'Database query failed.' );
		}
	}

	function logWrite( $str ) {
		try {
			$file = fopen( 'pdo.log', 'a' );
			fwrite( $file, '[' . date( "Y/m/d h:i:s A" ) . '] ' . $str . "\r\n" );
			fclose( $file );
		} catch( Exception $e ) {
			die( 'Error writing to log file.' );
		}
	}
}