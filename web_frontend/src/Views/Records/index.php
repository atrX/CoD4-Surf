<div class="controls">
	<div class="btn">
		<input type="button" name="button-all" id="button-all" value="Show All" onclick="showAll()">
	</div>

	<div class="btn">
		<input type="button" name="button-unique" id="button-unique" value="Show Unique" onclick="showUnique()">
	</div>

	<div id="search-map">
		<select id="mapname" name="mapname" onchange="setMap()">
			<?php foreach( $maps as $map ): ?>
				<option value="<?= $map[ 'map' ] ?>" <?php if( isset( $selectedMap ) && $map[ 'map' ] == $selectedMap ) echo 'selected'; ?>><?= $map[ 'map' ] ?></option>
			<?php endforeach; ?>
		</select>
	</div>
</div>

<?php if( count( $records ) > 0 ): ?>

<div class="record-legend">
	<div class="field">Position</div>
	<div class="field">Time</div>
	<div class="field">Map</div>
	<div class="field">Username</div>
</div>

<?php

foreach( $records as $key => $record ) {
	$ms = $record[ 'maptime' ];
	$seconds = 0;
	$minutes = 0;
	$hours = 0;
	$time = '';

	while( $ms >= 1000 * 60 * 60 ) {
		$hours++;
		$ms -= 1000 * 60 *60;
	}

	while( $ms >= 1000 * 60 ) {
		$minutes++;
		$ms -= 1000 * 60;
	}

	while( $ms >= 1000 ) {
		$seconds++;
		$ms -= 1000;
	}

	$ms = floor( $ms / 10 );

	if( $hours > 0 ) {
		$time .= $hours . ':';
	}

	if( $minutes < 10 ) {
		$time .= '0';
	}
	$time .= $minutes . ':';

	if( $seconds < 10 ) {
		$time .= '0';
	}
	$time .= $seconds . ':';

	if( $ms < 10 ) {
		$time .= '0';
	}
	$time .= $ms;

	echo '<div class="record">';
	echo '<div class="field">' . ( $key + 1 ) . '</div>';
	echo '<div class="field">' . $time . '</div>';
	echo '<div class="field">' . $record[ 'map' ] . '</div>';
	echo '<div class="field">' . $players[ $key ] . '</div>';
	echo '</div>';
}

endif;
?>