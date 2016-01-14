/*
	Copyright (C) 2016 Johan Mattsson

	This library is free software; you can redistribute it and/or modify 
	it under the terms of the GNU Lesser General Public License as 
	published by the Free Software Foundation; either version 3 of the 
	License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful, but 
	WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
	Lesser General Public License for more details.
*/

using Gee;
using B;

namespace Bird {
	
class VBox : BoxLayout {
	public VBox () {
		base (BoxOrientation.VERTICAL);
	}

	public VBox.for_tag (XmlElement layout) {
		base.for_tag (layout, BoxOrientation.VERTICAL);
	}
	
	public override string to_string () {
		return "VBox";
	}

}

}