<?php

class AppController {
	protected $app;

	public $template;

	public $autoRender = true;

	private $params = array();

	function __construct( $args ) {
		$this->app = App::instance();

		$this->set( [
			'title', APP_NAME
		] );
	}

	function set( $var ) {
		array_push( $this->params, $var );
	}

	function render( $template ) {
		$file = APP_PATH_VIEWS . "$template.php";

		if( file_exists( $file ) ) {
			foreach( $this->params as $param ) {
				$name = $param[0];
				$$name = $param[1];
			}
			
			include( $file );
		} else {
			echo "<h1>Template file &quot;$template.php&quot; not found!</h1>";
		}
	}
}