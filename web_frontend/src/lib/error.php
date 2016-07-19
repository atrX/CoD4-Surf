<?php

class _Error {
	function message( $msg = '', $status = 200 ) {
		http_response_code( $status );
		die( $msg );
	}
}