/**
 * 
 * Moko Eightball event data object
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
    public class AccelerometerEventData: GLib.Object {
        public int size {
            get;
            construct set;
        }
        
        public int length {
            get;
            private set;
            default = 0;
        }
        
        public AccelerometerEventDataNode? first {
            get;
            private set;
            default = null;
        }
        public AccelerometerEventDataNode? last {
            get;
            private set;
            default = null;
        }
        
        public AccelerometerEventData( int size ) {
            this.size = size;            
        }        

        construct {
            debug( "constructed" );
        }

        public void addValue( int x, int y, int z ) {
            var o = new AccelerometerEventDataNode();

            o.x = x;
            o.y = y;
            o.z = z;

            if ( this.last == null ) {
                this.last = o;
            }

            o.next = this.first;
            if ( this.first != null ) {
                this.first.prev = o;            
            }            
            this.first = o;

            if ( this.length + 1 > this.size ) {
                this.last = this.last.prev;
                this.last.next = null;
            }
            else {
                this.length++;
            }
        }

        public AccelerometerEventDataIterator createIterator() {
            return new AccelerometerEventDataIterator( this.first, false );                
        }
        
        public AccelerometerEventDataIterator createReverseIterator() {
            return new AccelerometerEventDataIterator( this.last, true );
        }

    }

    public class AccelerometerEventDataNode: GLib.Object {
        public AccelerometerEventDataNode prev = null;
        public AccelerometerEventDataNode next = null;
        public int x;
        public int y;
        public int z;
    }

    public class AccelerometerEventDataIterator: GLib.Object {
        public AccelerometerEventDataNode? current {
            get;
            construct set;
        }

        public bool reversed {
            get;
            construct set;
        }

        public AccelerometerEventDataIterator( AccelerometerEventDataNode node, bool reversed ) {
            this.current = node;
            this.reversed = reversed;
        }

        public AccelerometerEventDataNode next() {
            var cur = this.current;
            if ( this.current != null ) {
                if ( this.reversed ) {
                    this.current = this.current.prev;
                } 
                else {
                    this.current = this.current.next;
                }
            }
            return cur;
        }
    }
}
