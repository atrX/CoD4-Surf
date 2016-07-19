<div class="controls">
	<div id="search-cid">
		<input type="number" name="cid" id="cid" placeholder="Search for B3 CID..." onkeypress="searchPlayer( event )">
	</div>
</div>

<?php if( isset( $player ) ): ?>
	<div><!-- Most useless div ever but CSS for records table decided to fuck up if this wasn't here :( --></div>
	<div id="player-info">
		<div id="player-data">
			<?= ( $player[ 'vip' ] ? '<span title="This player is a VIP"><i class="fa fa-star vip" aria-hidden="true"></i></span>&nbsp;' : '' ) . $player[ 'name' ] ?> <span id="rank" title="<?= $player[ 'rankxp_surf' ] ?> XP gained">(Lvl <?= $player[ 'rank_surf' ] ?>)</span> <span id="cid" title="This player's B3 CID">(@<?= $cid ?>)</span>
		</div>
		<div id="player-maps-finished"><?= ( isset( $records ) && count( $records ) > 0 ? count( $records ) : '0' ) ?> Map(s) Finished</div>
	</div>

<?php endif; ?>

<?php if( isset( $records ) && count( $records ) > 0 ): ?>

	<div class="record-legend">
		<div class="field">Time</div>
		<div class="field">Map</div>
	</div>

	<?php

	foreach( $records as $record ) {
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
		echo '<div class="field">' . $time . '</div>';
		echo '<div class="field">' . $record[ 'map' ] . '</div>';
		echo '</div>';
	}

endif;
?>