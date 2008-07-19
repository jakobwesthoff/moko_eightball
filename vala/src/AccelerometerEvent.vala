/**
 * 
 * Moko Eightball event object
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
