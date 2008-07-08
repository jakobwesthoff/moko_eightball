using GLib;
using Gtk;
using Cairo;

namespace MokoEightBall {

    public class EightBallSurface: GLib.Object {
        
        protected HashTable<string, Cairo.ImageSurface> images;
        
        public DrawingArea area {
            get;
            construct set;
        }

        public EightBallSurface( DrawingArea area ) {
            this.area = area;
        }

        construct {
            this.loadImages();
            this.registerEvents();
        }

        protected void registerEvents() {
            this.area.expose_event += this.onExpose;
        }

        protected void loadImages() {
            this.images = new HashTable<string, Cairo.ImageSurface>( GLib.str_hash, GLib.str_equal );
            this.images.insert( 
                "eightball_front_face",
                new Cairo.ImageSurface.from_png( "data/eightball_front_face.png" )
            );
        }

        public bool onExpose( DrawingArea area, Gdk.Event e ) {
            var c = Gdk.cairo_create( area.window );
            
            this.drawBackground( c, e.expose );

            return true;
        }

        public void drawBackground( Cairo.Context c, Gdk.EventExpose e ) {
            c.save();

            c.set_source_surface( 
                this.images.lookup( "eightball_front_face" ),
                0, 0 
            );            
            c.rectangle( e.area.x, e.area.y, e.area.width, e.area.height );
            c.clip();
            c.paint();

            c.restore();

        }
    }

}
