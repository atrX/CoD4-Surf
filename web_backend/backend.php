<?php 

// Include necessary files
require_once( 'config.php' );
require_once( 'lib/db.php' );
require_once( 'lib/action.php' );

// Check if the correct API key was passed
if( !isset( $_POST[ 'apikey' ] ) ) {
	die( 'Error: No API key.' );
}

if( $_POST[ 'apikey' ] != API_KEY ) {
	die( 'Error: Invalid API key.' );
}

// Check if an action was passed
if( !isset( $_GET[ 'action' ] ) ) {
	die( 'Error: No action set.' );
}

// Create a new object for database interaction
$db = new DB();
$db->connect( SQL_DB );

// Call the correct method
$action = strtolower( $_GET[ 'action' ] );
if( file_exists( 'src/' . $action . '.php' ) ) {
	require_once( 'src/' . $action . '.php' );
} else {
	die( 'Error: Invalid action.' );
}

$action = ucwords( $action );
$handler = new $action( $db );