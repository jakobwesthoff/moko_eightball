using GLib;

namespace Jakob.Openmoko.Util {
    
    public class AccelerometerEventManager: GLib.Object {
        public signal void onMovement( AccelerometerEvent e );
        public signal void onShaking( AccelerometerEvent e );
        
        public int movementTolerance {
            get;
            set;
            default = 30;
        }

        public int shakingTolerance {
            get;
            set;
            default = 900;
        }
        public int neededShakes {
            get;
            set;
            default = 6;
        }

        protected int x = 0;
        protected int y = 0;
        protected int z = 0;

        protected AccelerometerEventData dataset;

        protected DataInputStream in;

        construct {
            // Init the dataset
            this.dataset = new AccelerometerEventData( 100 );            
            // We always need to make sure there are at least two events
            this.dataset.addValue( 0, 0, 0 );
            this.dataset.addValue( 0, 0, 0 );

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
                                // Add the new value pair to our dataset
                                this.dataset.addValue( this.x, this.y, this.z );
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
                                // Update to the new value
                                this.x = value;
                            break;
                            case 1:
                                // Update to the new value
                                this.y = value;
                            break;
                            case 2:
                                // Update to the new value
                                this.z = value;
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
            lock( this.movementTolerance ) {
                int tmp1 = this.dataset.first.x - this.dataset.first.next.x;
                tmp1 = tmp1 < 0 ? tmp1 * -1 : tmp1;
                int tmp2 = this.dataset.first.y - this.dataset.first.next.y;
                tmp2 = tmp2 < 0 ? tmp2 * -1 : tmp2;
                int tmp3 = this.dataset.first.z - this.dataset.first.next.z;
                tmp3 = tmp3 < 0 ? tmp3 * -1 : tmp3;
                
                if ( tmp1 > this.movementTolerance 
                || tmp2 > this.movementTolerance
                || tmp3 > this.movementTolerance ) {
                    // Create the needed event to emit
                    this.onMovement( this.createAccelerometerEvent() );

                    // Check for shaking event
                    // Therefore we need to check for acceleration in opposed direction
                    // with quite some force behind it.
                    lock( this.shakingTolerance ) {
                        int shake = 0;

                        int maxX = 0;
                        int maxY = 0;
                        int maxZ = 0;

                        var iter = this.dataset.createIterator();
                        AccelerometerEventDataNode? cur;
                        AccelerometerEventDataNode? last = null;
                        while( ( cur = iter.next() ) != null ) {
                            if ( last != null ) {
                                int tmp;

                                tmp = last.x - cur.x;
                                tmp = tmp < 0 ? tmp * -1 : tmp;
                                maxX = maxX > tmp ? maxX : tmp;

                                tmp = last.y - cur.y;
                                tmp = tmp < 0 ? tmp * -1 : tmp;
                                maxY = maxY > tmp ? maxY : tmp;

                                tmp = last.z - cur.z;
                                tmp = tmp < 0 ? tmp * -1 : tmp;
                                maxZ = maxZ > tmp ? maxZ : tmp;

                                if ( ( ( ( last.x < 0 && cur.x >0 ) || ( last.x > 0 && cur.x < 0 ) ) && ( maxX >= this.shakingTolerance ) )
                                || ( ( ( last.y < 0 && cur.y >0 ) || ( last.y > 0 && cur.y < 0 ) ) && ( maxY >= this.shakingTolerance ) )
                                || ( ( ( last.z < 0 && cur.z >0 ) || ( last.z > 0 && cur.z < 0 ) ) && ( maxZ >= this.shakingTolerance ) ) ) {
                                    shake++;
                                }
                            }
                            last = cur;
                        }
                        if ( shake >= this.neededShakes ) {
                            this.onShaking( this.createAccelerometerEvent() );
                        }
                    }
                }
            }
        }

        protected AccelerometerEvent createAccelerometerEvent() {
            return new AccelerometerEvent(
                this.dataset.first.x,
                this.dataset.first.y,
                this.dataset.first.z
            );
        }
    }
}
