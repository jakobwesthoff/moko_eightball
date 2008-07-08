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
            this.images.insert( 
                "eightball_back_face",
                new Cairo.ImageSurface.from_png( "data/eightball_back_face.png" )
            );
        }

        public bool onExpose( DrawingArea area, Gdk.Event e ) {
            var c = Gdk.cairo_create( area.window );
            
            this.drawBackground( c, e.expose );
            this.drawEightBall( c, e.expose );

            return true;
        }

        public void drawBackground( Cairo.Context c, Gdk.EventExpose e ) {
            c.save();

            int width, height;
            this.area.window.get_size( out width, out height );

            var gradient = new Cairo.Pattern.linear( 0, 0, 0, height );
            gradient.add_color_stop_rgb( 0, 0.99, 0.83, 0.58 );
            gradient.add_color_stop_rgb( 1, 0.96, 0.47, 0 );


            c.set_source( gradient );

            c.rectangle( e.area.x, e.area.y, e.area.width, e.area.height );
            c.fill();

            c.restore();
        }

        public void drawEightBall( Cairo.Context c, Gdk.EventExpose e ) {
            c.save();
            var image = this.images.lookup( "eightball_front_face" );
            int width, height;
            this.area.window.get_size( out width, out height );
            int image_width = image.get_width();
            int image_height = image.get_height();

            int movement_x = width/2 - image_width/2;
            int movement_y = height/2 - image_height/2;

            c.translate( movement_x, movement_y ); 

            c.set_source_surface( 
                image,
                0, 0 
            );            
            c.rectangle( e.area.x - movement_x, e.area.y - movement_y, e.area.width, e.area.height );
            c.clip();
            c.paint();

            c.restore();
        }
    }

}
