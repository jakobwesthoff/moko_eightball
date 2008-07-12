#!/bin/sh
. /usr/local/openmoko/arm/setup-env

valac --thread --pkg gtk+-2.0 --pkg cairo --pkg gio-2.0 -C *.vala

for i in MokoEightBall EightBallSurface AccelerometerEventManager AccelerometerEvent AccelerometerEventData; do
	arm-angstrom-linux-gnueabi-gcc `pkg-config --cflags gtk+-2.0 gio-2.0 cairo gthread-2.0` -c $i.c -o $i.o
done;

arm-angstrom-linux-gnueabi-gcc `pkg-config --libs gtk+-2.0 gio-2.0 cairo gthread-2.0`  *.o -o MokoEightBall

rm *.c *.h *.o
