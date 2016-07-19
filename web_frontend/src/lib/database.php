<?php

class Database {
	private $connection;

	function __construct( $user = null, $pass = null, $db = null ) {
		try {
			$this->connection = new PDO(
				'mysql:host=' . SQL_HOST . ';dbname=' . ( $db == null ? SQL_DB : $db ),
				( $user == null ? SQL_USER : $user ),
				( $pass == null ? SQL_PASS : $pass )
			);

			$this->connection->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
		} catch( PDOException $e ) {
			$this->logWrite( $e->getMessage() );
			new _Error( 'Connection to database could not be established.' );
		}
	}

	function __destruct() {
		$this->connection = null;
	}

	function query( $str ) {
		try {
			$statement = $this->connection->prepare( $str );
			$statement->execute();
			$statement->setFetchMode( PDO::FETCH_ASSOC );

			return $statement->fetchAll();
		} catch( PDOException $e ) {
			$this->logWrite( $e->getMessage() );
			new _Error( 'Database query failed.' );
		}
	}

	private function logWrite( $str ) {
		try {
			$file = fopen( APP_PATH_ROOT . 'pdo.log', 'a' );
			fwrite( $file, '[' . date( "Y/m/d h:i:s A" ) . '] ' . $str . "\r\n" );
			fclose( $file );
		} catch( Exception $e ) {
			new _Error( 'Error writing to log file.' );
		}
	}
}