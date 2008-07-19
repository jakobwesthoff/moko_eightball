############################################################################### 
# 
# Moko Eightball edje group 
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
