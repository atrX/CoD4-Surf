<?php

require_once( 'config.php' );

define( 'APP_PATH_ROOT', dirname( __FILE__ ) . '/' );
define( 'APP_PATH_SRC', APP_PATH_ROOT . 'src/' );
define( 'APP_PATH_LIBS', APP_PATH_SRC . 'lib/' );
define( 'APP_PATH_CONTROLLERS', APP_PATH_SRC . 'Controllers/' );
define( 'APP_PATH_VIEWS', APP_PATH_SRC . 'Views/' );

require_once( APP_PATH_LIBS . 'error.php' );
require_once( APP_PATH_LIBS . 'database.php' );
require_once( APP_PATH_LIBS . 'controller.php' );
require_once( APP_PATH_SRC . 'app.php' );
