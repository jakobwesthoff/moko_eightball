from __future__ import with_statement

import struct
import threading
import thread
import time

from math import fabs

class EventManager(threading.Thread):
	movementTolerance = 30
	shakeTolerance    = 600
	
	cycleLock = None

	listeners = dict( 
		shake = [],
		movement = []
	)

	acceleration = []

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
		# Make sure we always at least two value tuples in the accerlation list
		self.acceleration.append((0,0,0))
		self.acceleration.append((0,0,0))

		# Initialize the lock needed for thread safety
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
							# Add the values to the acceleration list
							self.addAccelerationData( x, y, z )
							# Inform all listeners
							self.informListeners()
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

	def addAccelerationData( self, x, y, z ):
		# Check if we already have reached the limit of values to be stored
		if ( len( self.acceleration ) >= 10 ):
			# Remove the last entry
			self.acceleration.pop( 9 )
		
		# Add the new data values
		self.acceleration.insert( 0, ( x, y, z ) )

	def informListeners( self ):
		x0, y0, z0 = self.acceleration[1]
		x1, y1, z1 = self.acceleration[0]

		if (   fabs( x0 - x1 ) >= self.movementTolerance
			or fabs( y0 - y1 ) >= self.movementTolerance
			or fabs( z0 - z1 ) >= self.movementTolerance ):
				for listener in self.listeners['movement']:
					listener( x0, y0, z0 )
