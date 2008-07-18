from __future__ import with_statement

import struct
import threading
import thread
import time

class EventManager(threading.Thread):
	movementTolerance = 30
	shakeTolerance    = 600
	
	cycleLock = None

	listeners = dict( 
		shake = [],
		movement = []
	)

	running = True

	def addListener( self, type, func ):
		self.listeners[type].append( func )
		print "added listener: ", func

	def setMovementTolerance( self, tolerance ):
		with self.cycleLock:
			self.movementTolerance = tolerance

	def setShakeTolerance( self, tolerance ):
		with self.cycleLock:
			self.shakeTolerance = tolerance

	def init( self ):
		self.eventInterface = open( "/dev/input/event2", "r" )
		self.cycleLock = thread.allocate_lock()

	def stop( self ):
		# Set the running flag to false
		self.running = False;
		# Join the thread until it is finished
		self.join()

	def run( self ):
		while( self.running ):
			with self.cycleLock:
				x = 0
				y = 0
				z = 0
				with open("/dev/input/event3", "r") as event:
					while( True ):
						# Read one datablock
						data = event.read(16)
						type, code, value = struct.unpack_from( "@HHi", data[8:] )
						if ( type == 0 and code == 0 ):
							# Syncronization
							# Inform all listeners
							self.informListeners( x, y, z )
							break
						if ( type == 2 and code == 0 ):
							# Update x
							x = value
							continue
						if ( type == 2 and code == 1 ):
							# Update y
							y = value
							continue
						if ( type == 2 and code == 2 ):
							# Update z
							z = value
							continue					
			time.sleep( 0.1 )

	def informListeners( self, x, y, z ):
		for listener in self.listeners['movement']:
			listener( x, y, z )
