using GLib;

namespace Jakob.Openmoko.Util {
    
    public class AccelerometerEventManager: GLib.Object {
        public signal void onMovement( AccelerometerEvent e );
        public signal void onShaking( AccelerometerEvent e );
        
        public int tolerance {
            get;
            set;
        }

        protected int[] x = new int[2];
        protected int[] y = new int[2];
        protected int[] z = new int[2];

        protected DataInputStream in;

        construct {
            // Initialize the attributes
            this.tolerance = 20;

            // Init the saved x,y,z values
            this.x[0] = 0;
            this.x[1] = 0;
            this.y[0] = 0;
            this.y[1] = 0;
            this.z[0] = 0;
            this.z[1] = 0;

            // Try to open the accelerometer mapped file
            try {
                File f = File.new_for_path( "/dev/input/event2" );
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
                short type, code;
                int value;
                try {
                    // Skip the timestamp
                    this.in.skip( 8, null );
                    
                    // Read the type
                    type = this.in.read_int16( null );
                    
                    // Read the code
                    code = this.in.read_int16( null );

                    // Read the value
                    value  = this.in.read_int32( null );
//                    stdout.printf( "type: %i, code: %i, value: %i\n", type, code, value );
                }
                catch ( GLib.Error e ) {
                    error( "Accelerometer data could not be read: %s\n", e.message );
                }

                switch( type ) {
                    case 0:
                        switch( code ) {
                            case 0:
                                // One update cycle is complete let's emit the needed signals
                                this.emitAllNeededSignals();
                            break;
                            default:
                                warning( "Unknown code ( 0x%02x ) for type 0x%02x\n", code, type );
                            break;
                        }
                    break;

                    case 2:
                        switch ( code ) {
                            case 0:
                                // Save the old value
                                this.x[1] = this.x[0];
                                // Update to the new one
                                this.x[0] = value;
                            break;
                            case 1:
                                // Save the old value
                                this.y[1] = this.y[0];
                                // Update to the new one
                                this.y[0] = value;
                            break;
                            case 2:
                                // Save the old value
                                this.z[1] = this.z[0];
                                // Update to the new one
                                this.z[0] = value;
                            break;
                            default:
                                warning( "Unknown code ( 0x%02x ) for type 0x%02x\n", code, type );
                            break;
                        }
                    break;

                    default:
                        warning( "Unknown type ( 0x%02x ) in accelerometer input stream\n", type );
                    break;
                }


            }
            return null;
        }

        protected void emitAllNeededSignals() {
            // If the acceleration is more than the given tolerance value on
            // any axis send the onMovement signal
            lock( this.tolerance ) {
                if (  Math.fabs( this.x[0] - this.x[1] ) > this.tolerance 
                   || Math.fabs( this.y[0] - this.y[1] ) > this.tolerance
                   || Math.fabs( this.z[0] - this.z[1] ) > this.tolerance ) {
                    // Create the needed event to emit
                    AccelerometerEvent event = this.createAccelerometerEvent();
                    this.onMovement( event );
                }
            }
        }

        protected AccelerometerEvent createAccelerometerEvent() {
            return new AccelerometerEvent(
                this.x[0],
                this.y[0],
                this.z[0]
            );
        }
    }
}
