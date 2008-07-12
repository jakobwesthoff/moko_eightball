using GLib;
using Gtk;

namespace MokoEightBall {

    public class MokoEightBall: Gtk.Window {
                
        protected EightBallSurface eightball;   

        construct {
            this.title = "Moko 8Ball";
            this.destroy += Gtk.main_quit;
            
            this.initializeDrawingArea();
        }

        protected void initializeDrawingArea() {
            var area = new DrawingArea();                   
            this.eightball = new EightBallSurface( area );           
            this.add( area );
        }

        static int main( string[] args ) {
            // Just for testing the accelerometer
            var accel = new Jakob.Openmoko.Util.AccelerometerEventManager();
            accel.onMovement += ( o, e ) => {
                stdout.printf( "MOVE x: %i, y: %i, z: %i\n", e.x, e.y, e.z );
            };

            accel.onShaking += ( o, e ) => {
                stdout.printf( "SHAKE x: %i, y: %i, z: %i\n", e.x, e.y, e.z );
            };

            Gtk.init( ref args );
            var app = new MokoEightBall();

            app.show_all();

            Gtk.main();

            return 0;
        }
    }

}

