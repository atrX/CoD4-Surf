<?php

class App {
	private static $instance;

	public $controller = DEFAULT_CONTROLLER;
	public $args = null;

	public $DB;

	static public function instance() {
		if( !self::$instance ) {
			self::$instance = new self();
		}

		return self::$instance;
	}

	function init() {
		// Create new object for database interaction
		$this->DB = new Database();

		// Handle request
		$this->requestHandler();
	}

	private function requestHandler() {
		if( isset( $_GET[ 'url' ] ) ) {
			// Turn url parameters into an array
			$url = $_GET[ 'url' ];
			$url = ltrim( $url, '/' );
			$url = rtrim( $url, '/' );
			$url = explode( '/', $url );

			// Set the controller name
			$this->controller = $url[0];

			// Check if any other arguments were passed
			if( isset( $url[1] ) ) {
				$this->args = array_slice( $url, 1 );
			}
		}

		// Create the controller object
		$this->controller = ucwords( strtolower( $this->controller ) ) . 'Controller';
		$file = APP_PATH_CONTROLLERS . $this->controller . '.php';
		if( file_exists( $file ) ) {
			require_once( $file );
		} else {
			new _Error( "Controller $this->controller not found." );
		}

		$this->controller = new $this->controller( $this->args );

		if( $this->controller->autoRender ) {
			$this->controller->render( 'header' );
			$this->controller->render( 'main' );
			$this->controller->render( $this->controller->template );
			$this->controller->render( 'footer' );
		}
	}
}