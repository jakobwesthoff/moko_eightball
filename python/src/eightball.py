#!/usr/bin/env python

############################################################################### 
# 
# Moko Eightball main application 
# 
# This file is part of Moko Eightball. 
# 
# Moko Eightball is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; version 3 of the License. 
# 
# Moko Eightball is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU General Public License for more details. 
# 
# You should have received a copy of the GNU General Public License 
# along with arbit; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA 
# 
############################################################################### 

import random
import math
import evas
import evas.decorators
import edje
import edje.decorators
import ecore
import ecore.evas

import Accelerometer
from eGroup import eGroup

class Eightball(object):
	engine = None
	ee = None
	size = ( 0, 0 )
	groups = {}
	accel = None
	shakeTimer = None

	def __init__( self, size ):
		# Check if we can use accelerated rendering
		if ecore.evas.engine_type_supported_get("software_x11_16"):
			self.engine = ecore.evas.SoftwareX11_16
   		else:
			print "warning: x11-16 is not supported, fallback to x11"
			self.engine = ecore.evas.SoftwareX11

		self.size = size
		
		# Init the Accelerometer Event Manager
		self.accel = Accelerometer.EventManager()

		# Set the acceleration callbacks
		self.accel.addListener( "shake", self.onShake )		

		# Initialize the renderer and set all initial properties
		self.ee = self.engine( w = size[0], h = size[1] )
		self.ee.title = "Moko Eightball"
		self.ee.name_class = ( "MOKO_EIGHTBALL", "MOKO_EIGHTBALL" )
#		self.ee.fullscreen = True
		self.ee.fullscreen = False

		# Register the needed callbacks
		self.ee.callback_resize         = self.onResize
		self.ee.callback_delete_request = self.onDelete		


	def onDelete( self, e ):
		self.shutdown()


	def onResize( self, e ):
		# Update the size of all edje groups on a window size change
		self.size = e.evas.rect.size
		
		for key in self.groups.keys():
			self.groups[key].size = self.size

	def onDisplayRandomAnswer( self, group, signal, source ):
		answers = [
			"as_i_see_it_yes",
			"ask_again_later",
			"better_not_tell_you_now",
			"cannot_predict_now",
			"concentrate_and_ask_again",
			"dont_count_on_it",
			"it_is_certain",
			"it_is_decidedly_so",
			"most_likely",
			"my_reply_is_no",
			"my_sources_say_no",
			"outlook_good",
			"outlook_not_so_good",
			"reply_hazy_try_again",
			"signs_point_to_yes",
			"very_doubtful",
			"without_a_doubt",
			"yes_definetly",
			"yes",
			"you_may_rely_on_it"
		];
		group.signal_emit( "%s_fade_in" % answers[int(math.floor(random.random() * 20))], "" )

	def onShake( self, count, acceleration ):
		if ( self.shakeTimer != None ):
			self.shakeTimer.delete()
			del self.shakeTimer
		self.shakeTimer = ecore.timer_add( 0.3, self.fireSwitchToBackEvent )

	def fireSwitchToBackEvent( self ):
		print "Firing \"switch_to_back\" event"
		self.getGroup( "eightball" ).signal_emit( "fade_out_answer", "" )
		self.getGroup( "eightball" ).signal_emit( "switch_to_back", "" )

	def run( self ):
		# Inititalize the Accelerometer
		self.accel.init()

		# Load the groups
		self.addGroup( "background" )
		self.addGroup( "eightball" )
		self.getGroup( "eightball" ).signal_callback_add( 
			"display_random_answer",
			"*",
			self.onDisplayRandomAnswer
		)

		self.ee.show()
		ecore.main_loop_begin()


	def shutdown( self ):
		ecore.main_loop_quit()


	def addGroup( self, group ):
		if group not in self.groups.keys():
			self.groups[group] = eGroup( self, group )
			self.groups[group].show()


	def getGroup( self, group ):
		return self.groups[group]

# Main initialization on program start
if __name__ == "__main__":
	app = Eightball( (480, 640) )
	try:
		app.run()
	except KeyboardInterrupt:
		app.shutdown()
		del app		
