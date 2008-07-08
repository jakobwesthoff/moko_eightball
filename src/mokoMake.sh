#!/bin/sh
valac --pkg gtk+-2.0 --pkg cairo -C *.vala

arm-angstrom-linux-gnueabi-gcc `pkg-config --cflags gtk+-2.0 cairo` -c MokoEightBall.c -o MokoEightBall.o

arm-angstrom-linux-gnueabi-gcc `pkg-config --cflags gtk+-2.0 cairo` -c EightBallSurface.c -o EightBallSurface.o

arm-angstrom-linux-gnueabi-gcc `pkg-config --libs gtk+-2.0 cairo`  MokoEightBall.o EightBallSurface.o -o MokoEightBall

rm *.c *.h
