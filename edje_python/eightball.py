#!/usr/bin/env python

import evas
import evas.decorators
import edje
import edje.decorators
import ecore
import ecore.evas

import eGroup

class Eightball(object):
	engine = None
	ee = None
	size = ( 0, 0 )
	groups = {}


	def __init__( self, size ):
		# Check if we can use accelerated rendering
		if ecore.evas.engine_type_supported_get("software_x11_16"):
			self.engine = ecore.evas.SoftwareX11_16
   		else:
			print "warning: x11-16 is not supported, fallback to x11"
			self.engine = ecore.evas.SoftwareX11

		self.size = size
		
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

	def run( self ):
		# Load the groups
		self.addGroup( "background" )
		self.addGroup( "eightball" )
		self.ee.show()
		ecore.main_loop_begin()


	def shutdown( self ):
		ecore.main_loop_quit()


	def addGroup( self, group ):
		if group not in self.groups.keys():
			self.groups[group] = eGroup.eGroup( self, group )
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
