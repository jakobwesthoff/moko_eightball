import Accelerometer

def onMovement( accel ):
	def tmp( f ):
		accel.addListener("movement", f)
		return f
	return tmp	
