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
                "front_face",
                new Cairo.ImageSurface.from_png( "data/front_face.png" )
            );
        }

        public bool onExpose( DrawingArea area, Gdk.Event e ) {
            var ctx = Gdk.cairo_create( area.window );
            
            ctx.save();

            ctx.set_source_surface( 
                this.images.lookup( "front_face" ),
                0, 0 
            );            
            ctx.rectangle( 0, 0, 300, 300 );
            ctx.clip();
            ctx.paint();

            ctx.restore();

            return true;
        }
    }

}
