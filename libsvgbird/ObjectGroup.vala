/*
	Copyright (C) 2015 Johan Mattsson

	This library is free software; you can redistribute it and/or modify 
	it under the terms of the GNU Lesser General Public License as 
	published by the Free Software Foundation; either version 3 of the 
	License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful, but 
	WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
	Lesser General Public License for more details.
*/

namespace SvgBird {

public class ObjectGroup : GLib.Object {
	public Gee.ArrayList<Object> objects;
	
	public int size { 
		get {
			return objects.size;
		}
	}
	
	public ObjectGroup () {
		 objects = new Gee.ArrayList<Object> ();
	}

	public Object get_object (int index) {
		if (unlikely (index < 0 || index >= size)) {
			warning ("Index out of bounds.");
			return new EmptyObject ();
		}
		
		return objects.get (index);
	}

	public int index_of (Object o) {
		return objects.index_of (o);
	}

	public Gee.Iterator<Object> iterator () {
		return objects.iterator ();
	}

	public void remove (Object p) {
		objects.remove (p);
	}
	
	public void add (Object p) {
		objects.add (p);
	}
	
	public void clear () {
		objects.clear ();
	}

	public void append (ObjectGroup group) {
		foreach (Object o in group.objects) {
			objects.add (o);
		}
	}
	
	public ObjectGroup copy () {
		ObjectGroup objects_copy = new ObjectGroup ();
		
		foreach (Object o in objects) {
			objects_copy.add (o.copy ());
		}
		
		return objects_copy;
	}
	
	public void print_objects () {
		foreach (Object o in objects) {
			stdout.printf (o.to_string ());
			stdout.printf ("\n");
		}
	}
}

}
