module ass

import strings

pub struct AssFile {
pub mut:
	script_info     ScriptInfo
	styles          []Style
	events          []Event
	custom_sections map[string]map[string]string
}

pub fn AssFile.parse(src_main string) !AssFile {
	return error('TODO:')
}

pub fn (this &AssFile) str() string {
	// let's use comptime reflection here :)
	//
	// EDIT V v0.5.0: seems like comptime have changed that field.attributes no
	// longer generates array of parsed attributes, our sole usable vector is
	// field.attrs, which is a []string, this means we have to mix comptime and
	// runtime
	mut bld := strings.new_builder(64)
	mut line := strings.new_builder(32)

	// write script info
	bld.write_string2('[Script Info]', '\n')
	$for field in ScriptInfo.fields {
		for attr in field.attrs {
			if attr.starts_with('ass_attr:') {
				mut attr_value := ''
				$if field.typ is string {
					attr_value = this.script_info.$(field.name)
				} $else {
					attr_value = this.script_info.$(field.name).str()
				}
				attr_key := attr["ass_attr:".len..].trim_space().trim('\"')
				bld.write_string2('${attr_key}: ${attr_value}', '\n')
			}
		}
	}
	bld.write_string('\n')

	// write custom sections
	for section_name, section_data in this.custom_sections {
		bld.write_string2('[${section_name}]', '\n')

		for key, value in section_data {
			bld.write_string2('${key}: ${value}', '\n')
		}
	}
	bld.write_string('\n')

	// write style info
	bld.write_string2('[V4+ Styles]', '\n')

	// -- style format
	ass_style_prefix := "ass_style:"
	bld.write_string("Format:")
	line.clear()

	$for field in Style.fields {
		for attr in field.attrs {
			if attr.starts_with(ass_style_prefix) {
				value := attr[ass_style_prefix.len..].trim_space()
				line.write_string(" ")
				line.write_string2(value, ",")
			}
		}
	}
	bld.write_string2(line.str().trim(','), "\n")

	for style in this.styles {
		line.clear()
		line.write_string("Style:")
		$for field in Style.fields {
			for attr in field.attrs {
				if attr.starts_with(ass_style_prefix) {
					mut value := "invalid"

					mut has_enum_int := false
					for f in field.attrs {
						if f.starts_with("ass_enum_int") {
							has_enum_int = true
							break
						}
					}

				 	match true {
						field.attrs.contains("ass_boolean_int") {
							$if field.typ is bool {
								value = (if style.$(field.name) { -1 } else { 0 }).str()
							}
						}
						has_enum_int {
							$if field.is_enum {
								value = unsafe { int(style.$(field.name)) }.str()
							}
						}
						else {
							$if field.typ is string {
								value = style.$(field.name)
							} $else {
								value = style.$(field.name).str()
							}
						}
					}

					line.write_string(" ")
					line.write_string2(value, ",")
				}
			}
		}
		bld.write_string2(line.str().trim_space().trim(','), "\n")
	}
	bld.write_string("\n")
	return bld.str()
}
