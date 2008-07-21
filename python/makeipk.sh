#!/bin/sh

cp src/eightball.py ipk/usr/bin/eightball
chmod u+x ipk/usr/bin/eightball

cp src/Accelerometer/*.py ipk/usr/share/moko_eightball/Accelerometer/

cd src/data/themes
./maketheme.sh
cd ../../../

cp src/data/themes/eightball.edj ipk/usr/share/moko_eightball/themes/eightball.edj

TEMP=`tempfile`

cp ipk/CONTROL/control "$TEMP"
sed -e "s@\\\$VERSIONSTRING\\\$@0.`date +%Y%m%d`@" -i ipk/CONTROL/control
sudo chown -R root:root ./ipk

sudo ipkg-build ipk ./

sudo chown -R jakob:users ./ipk

mv "$TEMP" ipk/CONTROL/control
