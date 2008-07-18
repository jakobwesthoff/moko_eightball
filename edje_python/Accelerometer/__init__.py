from __future__ import with_statement

import struct
import time
import ecore

from math import fabs

class EventManager(object):
	movementTolerance = 30
	shakeTolerance    = 2100

	listeners = dict( 
		shake = [],
		movement = []
	)

	timer = None

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

		# Register the timer
		self.timer = ecore.timer_add( 0.1, self.run )

	def stop( self ):
		if ( self.timer != None ):
			self.timer.delete()
			del self.timer

	def run( self ):
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
		return True

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

		# Inform all listeners if the movement tolerance was breached
		if (   fabs( x0 - x1 ) >= self.movementTolerance
			or fabs( y0 - y1 ) >= self.movementTolerance
			or fabs( z0 - z1 ) >= self.movementTolerance ):
				for listener in self.listeners['movement']:
					listener( x0, y0, z0 )

		# Inform listeners if shaking tolerance was breached
		shakeCount = 0
		maximumAcceleration = 0
		for i in range( len( self.acceleration ) - 1 ):
			if ( ( self.acceleration[i][0] > 0 and self.acceleration[i+1][0] < 0 )
			  or ( self.acceleration[i][0] < 0 and self.acceleration[i+1][0] > 0 )
			  or ( self.acceleration[i][1] > 0 and self.acceleration[i+1][1] < 0 )
			  or ( self.acceleration[i][1] < 0 and self.acceleration[i+1][1] > 0 )
			  or ( self.acceleration[i][2] > 0 and self.acceleration[i+1][2] < 0 )
			  or ( self.acceleration[i][2] < 0 and self.acceleration[i+1][2] > 0 ) ):
			  	shakeCount += 1
				maximumAcceleration = max( 
					maximumAcceleration,
					fabs( self.acceleration[i][0] - self.acceleration[i+1][0] ),
					fabs( self.acceleration[i][1] - self.acceleration[i+1][1] ),
					fabs( self.acceleration[i][2] - self.acceleration[i+1][2] )
				)
		if ( shakeCount >= 4 and maximumAcceleration >= self.shakeTolerance ):
			for listener in self.listeners['shake']:
				listener( shakeCount, maximumAcceleration )

