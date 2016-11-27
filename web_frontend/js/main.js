function setMap() {
	window.location = appUrl + '/records/' + $( '#mapname' ).val();
}

function showUnique() {
	window.location = appUrl + '/records/' + $( '#mapname' ).val() + '/1/unique';
}

function showAll() {
	window.location = appUrl + '/records/' + $( '#mapname' ).val() + '/1/all';
}

$( function() {
	$( '#main-container' ).fadeIn( 600 );
	
	$( '.pagination-button' ).click( function() {
		var url = appUrl + '/records/' + $( '#mapname' ).val() + '/' + $( this ).data( 'page' );

		if( $( this ).data( 'unique' ) ) {
			url += '/unique';
		} else {
			url += '/all';
		}

		window.location = url;
	} );
} );

function searchPlayer( e ) {
	if( e.keyCode == 13 ) {
		window.location = appUrl + '/stats/' + $( '#cid' ).val();
	}
}