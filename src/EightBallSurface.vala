using GLib;
using Gtk;
using Cairo;

namespace MokoEightBall {

    public class EightBallSurface: GLib.Object {
        
        protected HashTable<string, Cairo.ImageSurface> images;
        protected Cairo.ImageSurface[] answers;
        protected Cairo.ImageSurface currentAnswer;

        public DrawingArea area {
            get;
            construct set;
        }

        public EightBallSurface( DrawingArea area ) {
            this.area = area;
        }

        construct {
            this.loadImages();
            this.selectRandomAnswer();
            this.registerEvents();
        }

        protected void registerEvents() {
            this.area.events = Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.EXPOSURE_MASK;
            this.area.expose_event += this.onExpose;
            this.area.button_release_event += this.onButtonRelease;
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

            this.answers = new Cairo.ImageSurface[20];
            this.answers[0] = new Cairo.ImageSurface.from_png( "data/answers/as_i_see_it_yes.png" );
            this.answers[1] = new Cairo.ImageSurface.from_png( "data/answers/ask_again_later.png" );
            this.answers[2] = new Cairo.ImageSurface.from_png( "data/answers/better_not_tell_you_now.png" );
            this.answers[3] = new Cairo.ImageSurface.from_png( "data/answers/cannot_predict_now.png" );
            this.answers[4] = new Cairo.ImageSurface.from_png( "data/answers/concentrate_and_ask_again.png" );
            this.answers[5] = new Cairo.ImageSurface.from_png( "data/answers/dont_count_on_it.png" );
            this.answers[6] = new Cairo.ImageSurface.from_png( "data/answers/it_is_certain.png" );
            this.answers[7] = new Cairo.ImageSurface.from_png( "data/answers/it_is_decidedly_so.png" );
            this.answers[8] = new Cairo.ImageSurface.from_png( "data/answers/most_likely.png" );
            this.answers[9] = new Cairo.ImageSurface.from_png( "data/answers/my_reply_is_no.png" );
            this.answers[10] = new Cairo.ImageSurface.from_png( "data/answers/my_sources_say_no.png" );
            this.answers[11] = new Cairo.ImageSurface.from_png( "data/answers/outlook_good.png" );
            this.answers[12] = new Cairo.ImageSurface.from_png( "data/answers/outlook_not_so_good.png" );
            this.answers[13] = new Cairo.ImageSurface.from_png( "data/answers/reply_hazy_try_again.png" );
            this.answers[14] = new Cairo.ImageSurface.from_png( "data/answers/signs_point_to_yes.png" );
            this.answers[15] = new Cairo.ImageSurface.from_png( "data/answers/very_doubtful.png" );
            this.answers[16] = new Cairo.ImageSurface.from_png( "data/answers/without_a_doubt.png" );
            this.answers[17] = new Cairo.ImageSurface.from_png( "data/answers/yes.png" );
            this.answers[18] = new Cairo.ImageSurface.from_png( "data/answers/yes_definetly.png" );
            this.answers[19] = new Cairo.ImageSurface.from_png( "data/answers/you_may_rely_on_it.png" );
        }

        protected bool onExpose( DrawingArea area, Gdk.Event e ) {
            var c = Gdk.cairo_create( area.window );
            
            this.drawBackground( c, e.expose );
            this.drawEightBall( c, e.expose );
            this.drawRandomAnswer( c, e.expose );

            return true;
        }

        protected void drawBackground( Cairo.Context c, Gdk.EventExpose e ) {
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

        protected void drawEightBall( Cairo.Context c, Gdk.EventExpose e ) {
            c.save();
            var image = this.images.lookup( "eightball_back_face" );
            int movementX, movementY;
            this.calculateCenterPosition( 
                image.get_width(), 
                image.get_height(),
                out movementX,
                out movementY
            );

            c.translate( movementX, movementY ); 

            c.set_source_surface( 
                image,
                0, 0 
            );            
            c.rectangle( e.area.x - movementX, e.area.y - movementY, e.area.width, e.area.height );
            c.clip();
            c.paint();

            c.restore();
        }

        protected void drawRandomAnswer( Cairo.Context c, Gdk.EventExpose e ) {
            c.save();

            // Center the answer on the display
            int movementX, movementY;
            this.calculateCenterPosition( 
                this.currentAnswer.get_width(), 
                this.currentAnswer.get_height(), 
                out movementX, 
                out movementY
            );

            c.translate( movementX, movementY ); 

            // Select the currentAnswer for drawing
            c.set_source_surface( 
                this.currentAnswer,
                0, 0 
            );            
            
            // Clip it to the drawing area
            c.rectangle( e.area.x - movementX, e.area.y - movementY, e.area.width, e.area.height );
            c.clip();

            // Paint the currentAnswer
            c.paint();

            c.restore();
        }

        protected void calculateCenterPosition( int width, int height, out int movementX, out int movementY ) {
            int window_width, window_height;
            this.area.window.get_size( out window_width, out window_height );

            movementX = window_width/2 - width/2;
            movementY = window_height/2 - height/2;
        }

        protected bool onButtonRelease( Gtk.DrawingArea area, Gdk.Event e ) {
            this.selectRandomAnswer();

            // Calculate the exact area which needs to be redrawn           
            int movementX, movementY;
            int image_width = this.currentAnswer.get_width();
            int image_height = this.currentAnswer.get_height();
            this.calculateCenterPosition( image_width, image_width, out movementX, out movementY );
            this.area.queue_draw_area( movementX, movementY, image_width, image_height );

            return true;
        }

        protected void selectRandomAnswer() {
            // Get a new random answer image            
            this.currentAnswer = this.answers[Random.int_range( 0, 19 )];
        }
    }

}
