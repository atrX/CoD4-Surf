__version__ = '1.0'
__author__  = 'atrX'

import b3
import b3.events
import b3.plugin

import math

class SurfPlugin( b3.plugin.Plugin ):
	requiresConfigFile = False

	voteStarted = False

	def onStartup( self ):
		self._adminPlugin = self.console.getPlugin( 'admin' )
		if not self._adminPlugin:
			self.error( 'Could not find admin plugin' )
			return False

		self.registerEvent( 'EVT_GAME_ROUND_START', self.onRoundStart )
		self.registerEvent( 'EVT_CLIENT_CONNECT', self.onConnect )

		self._adminPlugin.registerCommand( self, 'rtv', 0, self.cmd_rtv )
		self._adminPlugin.registerCommand( self, 'extend', 0, self.cmd_extend, 'extendtimer' )
		self._adminPlugin.registerCommand( self, 'retry', 0, self.cmd_retry, 're' )
		self._adminPlugin.registerCommand( self, 'setrank', 80, self.cmd_setrank )
		self._adminPlugin.registerCommand( self, 'tutorial', 0, self.cmd_tutorial )

		self.console.say( 'Surf Plugin 1.0 by atrX Loaded!' )

	def onRoundStart( self, event ):
		self.voteStarted = False
		
		for client in self.console.clients.getList():
			client.rtvDone = 0
	
	def onConnect( self, event ):
		event.client.rtvDone = 0
	
	def cmd_rtv( self, data, client, cmd = None ):
		"""\
		Vote to start a mapvote.
		"""
		if self.voteStarted:
			client.message( '^7A vote has already started!' )
			return
			
		rtvs = 0
			
		if client.rtvDone != 1:
			client.rtvDone = 1
			
			for cl in self.console.clients.getList():
				if cl.rtvDone == 1:
					rtvs += 1
				
			clientCount = len( self.console.clients.getList() )

			self.console.say( '^7%s^7 wants to rock the vote!' % client.exactName )

			if rtvs > clientCount * .66:
				self.voteStarted = True
				self.console.say( '^7Enough players voted, launching map vote!' )
				self.console.setCvar( 'surf_votemap', '1' )
			else:
				self.console.say( '^7%i^7 more votes required.' % ( math.ceil( clientCount * .66 ) - rtvs ) )
		else:
			client.message( '^7You have already voted to change the map' )
	
	def cmd_extend( self, data, client, cmd = None ):
		"""\
		Extend the map timer.
		"""
		self.console.say( '^7%s^7 wants to extend the timer!' % client.exactName )
		self.console.setCvar( 'surf_extend_timer', '1' )
	
	def cmd_retry( self, data, client, cmd = None ):
		"""\
		Reset your timer and go back to spawn.
		"""
		self.console.setCvar( 'surf_respawn_%s' % client.cid, '1' )

	def cmd_setrank( self, data, client, cmd = None ):
		"""\
		<player> <rank> - Set a player's rank.
		"""
		# this will split the player name and the message
		input = self._adminPlugin.parseUserCmd( data )
		if input:
			# input[0] is the player id
			sclient = self._adminPlugin.findClientPrompt( input[0], client )
			if not sclient:
				# a player matching the name was not found, a list of closest matches will be displayed
				# we can exit here and the user will retry with a more specific player
				return False
		else:
			client.message( '^7Invalid data, try !help setrank' )
			return False
		
		sclient.message( '^3You rank is being set to level ^7%s' % input[1] )
		
		self.console.setCvar( 'surf_setrank_rank', '%s' % input[1] )
		self.console.setCvar( 'surf_setrank_id', '%s' % sclient.cid )
		
		return True

	def cmd_tutorial( self, data, client, cmd = None ):
		"""\
		Show a link to a YouTube tutorial on how to surf.
		"""
		message = "^3If you're new to surf you can check out this tutorial: ^1youtube.com/watch?v=PtLsrwES964"
		
		if cmd.loud or cmd.big:
			self.console.say( message )
		else:
			client.message( message )
