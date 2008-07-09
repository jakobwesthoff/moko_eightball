using GLib;

namespace Jakob.Openmoko.Util {
    
    public class AccelerometerEventManager: GLib.Object {
        public signal void onMovement( AccelerometerEvent e );
        public signal void onShaking( AccelerometerEvent e );
        
        protected int x;
        protected int y;
        protected int z;

        protected DataInputStream in;

        construct {
            // Try to open the accelerometer mapped file
            try {
                File f = File.new_for_path( "/dev/input/event3" );
                if ( !f.query_exists( null ) ) {
                    error( "The input device \"%s\" does not exist.\n", f.get_path() );
                }
                var inputStream = f.read( null );
                this.in = new DataInputStream( inputStream );
                this.in.byte_order = DataStreamByteOrder.LITTLE_ENDIAN;
            }
            catch ( GLib.Error e ) {
                error( "Accelerometer device could not be opened: %s\n", e.message );
            }

            try {
                Thread.create( this.processInputEvents, false );
            }
            catch ( ThreadError e ) {
                error( "Accelerometer reading thread could not be created: %s\n", e.message );
            }
        }

        public void* processInputEvents() {
            while( true ) {
                // Skip the timestamp
                try {
                    this.in.skip( 8, null );
                    short type = this.in.read_int16( null );
                    short code = this.in.read_int16( null );
                    int value  = this.in.read_int32( null );
                    stdout.printf( "type: %i, code: %i, value: %i\n", type, code, value );
                }
                catch ( GLib.Error e ) {
                    error( "Accelerometer data could not be read: %s\n", e.message );
                }
            }
            return null;
        }
    }

}
