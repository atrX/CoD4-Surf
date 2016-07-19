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
		self._adminPlugin.registerCommand( self, 'retry', 0, self.cmd_retry, 're' )

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
				self.console.write( 'surf_votemap 1' )
			else:
				self.console.say( '^7%i^7 more votes required.' % ( math.ceil( clientCount * .66 ) - rtvs ) )
		else:
			client.message( '^7You have already voted to change the map' )
	
	def cmd_retry( self, data, client, cmd = None ):
		"""\
		Reset your timer and go back to spawn.
		"""
		self.console.write( 'surf_respawn_%s 1' % client.cid )