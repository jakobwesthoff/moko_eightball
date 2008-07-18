import Accelerometer
import Accelerometer.decorators

import time

def onMovement(x,y,z):
	print("X=%i, Y=%i, Z=%i" % (x,y,z))

x = Accelerometer.EventManager()
x.init()
x.addListener( "movement", onMovement )
x.start()
time.sleep(10)
x.stop()

