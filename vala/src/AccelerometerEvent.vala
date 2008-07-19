using GLib;

namespace Jakob.Openmoko.Util {
    public class AccelerometerEvent: GLib.Object {
        public int x {
            get;
            construct set;
        }
        public int y {
            get;
            construct set;
        }
        public int z {
            get;
            construct set;
        }

        public AccelerometerEvent( int x, int y, int z ) {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        construct {
//            stdout.printf( "%i, %i, %i\n", this.x, this.y, this.z );
        }
    }
}
