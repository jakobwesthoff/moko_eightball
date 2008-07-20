#!/bin/sh

cp src/eightball.py ipk/usr/bin/eightball
chmod u+x ipk/usr/bin/eightball

cp src/Accelerometer/*.py ipk/usr/share/moko_eightball/Accelerometer/

cd src/data/themes
./maketheme.sh
cd ../../../

cp src/data/themes/eightball.edj ipk/usr/share/moko_eightball/themes/eightball.edj

chown -R root:root ./ipk

ipkg-build ipk ./

