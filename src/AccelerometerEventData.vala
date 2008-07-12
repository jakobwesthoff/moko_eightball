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
        
        public AccelerometerEventDataNode* first {
            get;
            private set;
            default = null;
        }
        public AccelerometerEventDataNode* last {
            get;
            private set;
            default = null;
        }
        
        public AccelerometerEventData( int size ) {
            this.size = size;            
        }        

        public void addValue( int x, int y, int z ) {
            AccelerometerEventDataNode* o = new AccelerometerEventDataNode();

            o->x = x;
            o->y = y;
            o->z = z;

            o->next = this.first;
            this.first->prev = o;            
            this.first = o;

            if ( this.length + 1 > this.size ) {
                this.last = this.last->prev;
                delete this.last->next;
                this.last->next = null;
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
        public AccelerometerEventDataNode* prev = null;
        public AccelerometerEventDataNode* next = null;
        public int x;
        public int y;
        public int z;
    }

    public class AccelerometerEventDataIterator: GLib.Object {
        public AccelerometerEventDataNode* current {
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

        public weak AccelerometerEventDataNode next() {
            var cur = this.current;
            if ( this.current != null ) {
                if ( this.reversed ) {
                    this.current = this.current->prev;
                } 
                else {
                    this.current = this.current->next;
                }
            }
            return cur;
        }
    }
}
