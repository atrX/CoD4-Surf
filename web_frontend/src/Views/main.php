<body>

<div id="main-container">
	<div id="sidebar">
		<a href="<?php echo APP_URL; ?>" title="<?php echo APP_NAME; ?>">
			<div class="header">
				<img src="<?php echo APP_URL; ?>/img/logo.png" alt="<?php echo APP_NAME; ?>">
			</div>
		</a>

		<a class="navitem" href="<?php echo APP_URL . '/records/'; ?>">
			Records
		</a>

		<a class="navitem" href="<?php echo APP_URL . '/stats/'; ?>">
			Statistics
		</a>

		<div class="copyright">
			Copyright &copy; Revolutionary Mods 2016<?php if( date( 'Y' ) > 2016 ) echo ' - ' . date( 'Y' ); ?>
		</div>
	</div>

	<div id="content">
