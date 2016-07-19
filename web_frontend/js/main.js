function setMap() {
	window.location = appUrl + '/records/' + $( '#mapname' ).val();
}

function showUnique() {
	window.location = appUrl + '/records/' + $( '#mapname' ).val() + '/unique';
}

function showAll() {
	window.location = appUrl + '/records/' + $( '#mapname' ).val() + '/all';
}

$( function() {
	$( '#main-container' ).fadeIn( 600 );
} );

function searchPlayer( e ) {
	if( e.keyCode == 13 ) {
		window.location = appUrl + '/stats/' + $( '#cid' ).val();
	}
}