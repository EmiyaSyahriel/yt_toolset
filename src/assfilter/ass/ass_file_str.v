module ass

import strings
import time

fn (this &AssFile) str_script_info(mut line strings.Builder, mut bld strings.Builder) {
	bld.write_string2('[Script Info]', '\n')
	_ = line

	$for field in ScriptInfo.fields {
		for attr in field.attrs {
			if attr.starts_with(ass_attr_prefix) {
				mut attr_value := ''

				$if field.typ is string {
					attr_value = this.script_info.$(field.name)
				} $else {
					attr_value = this.script_info.$(field.name).str()
				}
				attr_key := attr[ass_attr_prefix.len..].trim_space().trim('"')

				if field.attrs.contains(ass_optional_flag) && attr_value.len == 0 {
					continue
				}

				bld.write_string2('${attr_key}: ${attr_value}', '\n')
			}
		}
	}

	for k, v in this.script_info.custom_data {
		bld.write_string2("${k}: ${v}", "\n")
	}

	bld.write_string('\n')
}

fn (this &AssFile) str_custom_section(mut line strings.Builder, mut bld strings.Builder) {
	_ = line
	for section_name, section_data in this.custom_sections {
		bld.write_string2('[${section_name}]', '\n')

		for key, value in section_data {
			bld.write_string2('${key}: ${value}', '\n')
		}
	}
	bld.write_string('\n')
}

fn (this &AssFile) str_style(mut line strings.Builder, mut bld strings.Builder) {
	bld.write_string2('[V4+ Styles]', '\n')

	// format
	line.clear()
	line.write_string('Format:')

	$for field in Style.fields {
		for attr in field.attrs {
			if attr.starts_with(ass_style_prefix) {
				value := attr[ass_style_prefix.len..].trim_space()
				line.write_string(' ')
				line.write_string2(value, ',')
			}
		}
	}
	bld.write_string2(line.str().trim(','), '\n')

	// style lists
	for style in this.styles {
		line.clear()
		line.write_string('Style:')
		$for field in Style.fields {
			for attr in field.attrs {
				if attr.starts_with(ass_style_prefix) {
					mut value := 'invalid'

					match true {
						field.attrs.contains('ass_boolean_int') {
							$if field.typ is bool {
								value = (if style.$(field.name) { -1 } else { 0 }).str()
							}
						}
						field.attrs.contains('ass_enum_int') {
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
					line.write_string2(value, ',')
				}
			}
		}
		bld.write_string2(line.str().trim_space().trim(','), '\n')
	}

	bld.write_string('\n')
}

fn (this &AssFile) str_events(mut line strings.Builder, mut bld strings.Builder) {
	bld.write_string2('[Events]', '\n')

	// format
	line.clear()
	line.write_string('Format:')

	$for field in Event.fields {
		for attr in field.attrs {
			if attr.starts_with(ass_event_prefix) {
				value := attr[ass_event_prefix.len..].trim_space().trim('"')
				line.write_string(' ')
				line.write_string2(value, ',')
			}
		}
	}
	bld.write_string2(line.str().trim(','), '\n')

	// event lists
	for event in this.events {
		line.clear()

		n := event.kind.str()
		line.write_string2(n, ": ")

		$for field in Event.fields {
			for attr in field.attrs {
				if attr.starts_with(ass_event_prefix) {
					mut value := "invalid"

					match true {
						field.attrs.contains("ass_time") {
							$if field.typ is time.Duration {
								m_time := event.$(field.name)
								h := i64(m_time.hours())
								m := i64(m_time.minutes()) % 60
								s := i64(m_time.seconds()) % 60
								ms := i64(f64(m_time.milliseconds()) / 10.0) % 100
								value = "${h}:${m:02d}:${s:02d}.${ms:02d}"
							}
						}
						else {
							$if field.typ is string {
								$if field.name == "text" {
									mut text_data := event.$(field.name)
									text_data = text_data.replace("\n", "\\N")
									value = text_data
								} $else {
									value = event.$(field.name)
								}
							} $else {
								value = event.$(field.name).str()
							}
						}
					}

					line.write_string2(value, ',')
				}
			}
		}

		bld.write_string2(line.str().trim_space().trim(','), '\n')
	}
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

	this.str_script_info(mut line, mut bld)
	this.str_custom_section(mut line, mut bld)
	this.str_style(mut line, mut bld)
	this.str_events(mut line, mut bld)

	return bld.str()
}
