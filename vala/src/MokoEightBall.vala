/**
 * 
 * Moko Eightball main application
 * 
 * Moko Eightball is free software; you can redistribute it and/or modify 
 * it under the terms of the GNU General Public License as published by 
 * the Free Software Foundation; version 3 of the License. 
 * 
 * Moko Eightball is distributed in the hope that it will be useful, 
 * but WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 * GNU General Public License for more details. 
 * 
 * You should have received a copy of the GNU General Public License 
 * along with arbit; if not, write to the Free Software 
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA 
 * 
 */

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
            Gtk.init( ref args );
            var app = new MokoEightBall();

            app.show_all();

            Gtk.main();

            return 0;
        }
    }

}

