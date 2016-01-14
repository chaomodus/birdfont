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

using B;
using SvgBird;
using Gee;
using Cairo;

namespace Bird {

class Component : GLib.Object {
	public double width { get; protected set; }
	public double height { get; protected set; }
	
	public double padded_width {
		get {
			return width + get_padding_top () + get_padding_bottom ();
		}
	}
	
	public double padded_height { 
		get {
			return height + get_padding_left () + get_padding_right ();
		}
	}
	
	/** Vertical placement for this component relative to the parent container. */
	public double x { get; protected set; }
	
	/** Horizontal placement for this component relative to the parent container. */
	public double y { get; protected set; }

	/** The parts this component is made of. */
	protected ArrayList<Component> components = new ArrayList<Component> ();

	XmlElement? component_tag = null;
	
	/** Style sheet and other SVG definitions. */
	Defs? defs = null;
	SvgStyle style = new SvgStyle ();

	string? css_class = null;
	string? id = null;

	public Component () {
	}

	public Component.for_tag (XmlElement component_tag) {
		this.component_tag = component_tag;
		parse (component_tag);
	}

	private void inherit_style (Defs? defs) {
		this.defs = defs;
	}

	protected void apply_padding () {	
	}

	protected void load_svg_file (string file_name) {
		SvgComponent svg = new SvgComponent.for_file (file_name);
		add_component (svg);		
	}

	protected void parse_style (XmlElement style_tag) {
		Defs definitions = new Defs ();		
		StyleSheet style_sheet = StyleSheet.parse (definitions, style_tag);
		
		if (defs != null) {
			Defs subscope_definitions = ((!) defs).shallow_copy ();
			subscope_definitions.style_sheet.merge (style_sheet);
		} else {
			defs = definitions;
		}
	}
	
	protected void parse_svg (XmlElement svg_tag) {
		foreach (Attribute attribute in svg_tag.get_attributes ()) {
			string attribute_name = attribute.get_name ();
			
			if (attribute_name == "file") {
				load_svg_file (attribute.get_content ());
			}
		}
	}

	protected void add_component (Component component) {
		components.add (component);
		component.inherit_style (defs);
		
		if (component.component_tag != null) {
			style = SvgStyle.parse (defs, style, (!) component.component_tag);
		}
	}

	protected void parse_layout (XmlElement layout_tag) {
		foreach (Attribute attribute in layout_tag.get_attributes ()) {
			string attribute_name = attribute.get_name ();
			
			if (attribute_name == "type") {
				if (attribute.get_content () == "hbox") {
					HBox hbox = new HBox.for_tag (layout_tag);
					add_component (hbox);
				} else if (attribute.get_content () == "vbox") {
					VBox hbox = new VBox.for_tag (layout_tag);
					add_component (hbox);
				} else {
					warning ("Layout of type " + attribute.get_content ()
						+ " is not implemented in this verison.");
				}
			} else if (attribute_name == "id") {
				id = attribute.get_content ();
			} else if (attribute_name == "class") {
				css_class = attribute.get_content ();
			} else if (attribute_name == "style") {
				// style will be parsed later
			} else {
				unused_attribute (attribute_name);
			}
		}
	}

	protected void parse_component (XmlElement component_tag) {
		foreach (Attribute attribute in component_tag.get_attributes ()) {
			string attribute_name = attribute.get_name ();
			
			if (attribute_name == "file") {
				Component component = new Component ();
				component.load (attribute.get_content ());
				add_component (component);
			} else {
				unused_attribute (attribute_name);
			}
		}
	}
	
	protected void parse (XmlElement component_tag) {
		foreach (XmlElement tag in component_tag) {
			string tag_name = tag.get_name ();
			
			if (tag_name == "ui") {
				parse (tag);
			} else if (tag_name == "layout") {
				parse_layout (tag);
			} else if (tag_name == "component") {
				parse_component (tag);
			} else if (tag_name == "svg") {
				parse_svg (tag);
			} else if (tag_name == "style") {
				parse_style (tag);
			} else {
				unused_tag (tag_name);
			}
		}
	}

	internal void unused_attribute (string attribute) {
		warning ("The attribute " + attribute + " is not known in this version.");
	}
	
	internal void unused_tag (string tag_name) {
		warning ("The tag " + tag_name + " is not known in this version.");
	}

	public void load (string file_name) {
		if (file_name.has_suffix (".ui")) {
			load_layout (file_name);
		} else if (file_name.has_suffix (".svg")) {
			load_svg_file (file_name);
		} else {
			warning (file_name + " is not a ui file or svg file.");
		}
	}

	public void load_layout (string file_name) {
		string? path = find_file (file_name);
		
		if (path == null) {
			warning (file_name + " not found.");
			return;
		}
		
		string xml_data;
		File layout_file = File.new_for_path ((!) path); 
		
		try {
			FileUtils.get_contents((!) layout_file.get_path (), out xml_data);
		} catch (GLib.Error error) {
			warning (error.message);
			return;
		}

		XmlTree xml_parser = new XmlTree (xml_data);
		Component component = new Component.for_tag (xml_parser.get_root ());
		add_component (component);
		layout ();
	}
	
	public static string find_file (string file_name) {
		File file = File.new_for_path ("birdui/" + file_name);
		
		if (file.query_exists ()) {
			return (!) file.get_path ();
		}
		
		return file_name;
	}
	
	public virtual void layout () {
		if (unlikely (components.size > 1)) {
			warning ("A component has several parts but no layout has been set.");
		}
		
		foreach (Component component in components) {
			component.layout ();
			component.apply_padding ();
			width = component.padded_width;
			height = component.padded_height;
		}
	}
	
	public virtual void draw (Context cairo) {
		foreach (Component component in components) {
			cairo.save ();
			cairo.translate (component.x, component.y);
			component.draw (cairo);
			cairo.restore ();
		}
	}
	
	public virtual void motion_notify_event (double x, double y) {	
	}
	
	public virtual void button_press_event (uint button, double x, double y) {	
	}
	
	public virtual string to_string () {
		if (component_tag != null) {
			XmlElement tag = (!) component_tag;
			return @"Component $(tag.get_name ())";
		} else {
			
			return "Component";
		}
	}
	
	public void print_tree () {
		print_tree_level (0);
	}

	protected void print_tree_level (int indent) {
		for (int i = 0; i < indent; i++) {
			print ("\t");
		}
		
		print (@"$(to_string ()), x: $x, y: $y, w: $width, h: $height\n");
		
		foreach (Component component in components) {
			component.print_tree_level (indent + 1);
		}
	}
	
	double get_padding_bottom () {
		return SvgFile.parse_number (style.get_css_property ("padding-bottom"));
	}

	double get_padding_top () {
		return SvgFile.parse_number (style.get_css_property ("padding-top"));
	}

	double get_padding_left () {
		return SvgFile.parse_number (style.get_css_property ("padding-left"));
	}

	double get_padding_right () {
		return SvgFile.parse_number (style.get_css_property ("padding-right"));
	}
}

}
