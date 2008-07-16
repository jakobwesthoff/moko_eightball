import edje
import edje.decorators

class eGroup(edje.Edje):
	def __init__( self, app, group ):
		theme = "data/themes/eightball.edj"
		try:
			edje.Edje.__init__( self, app.ee.evas, file = theme, group = group )
		except edje.EdjeLoadError, e:
			raise SystemExit( "Could not load theme file: \"%s\"" % theme )

		# Set the currently registered size
		self.size = app.size
