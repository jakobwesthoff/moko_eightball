import Accelerometer
import Accelerometer.decorators

import time


x = Accelerometer.EventManager()
x.init()
#x.addListener( "movement", onMovement )
x.start()
time.sleep(10)
x.stop()

@Accelerometer.decorators.onMovement(x)
def onMovement(x,y,z):
	print("X=%i, Y=%i, Z=%i" % (x,y,z))
