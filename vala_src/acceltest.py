import Accelerometer

import time

def onMovement(x,y,z):
	print("MOVEMENT: X=%i, Y=%i, Z=%i" % (x,y,z))

def onShake(count, acceleration):
	print("SHAKE: count=%i, acceleration=%i" % (count, acceleration))

x = Accelerometer.EventManager()
x.init()
x.addListener( "movement", onMovement )
x.addListener( "shake", onShake )
x.start()
time.sleep(10)
x.stop()

