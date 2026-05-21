module ass

import strconv

pub struct AssFile {
pub mut:
	script_info     ScriptInfo
	styles          []Style
	events          []Event
	custom_sections map[string]map[string]string
}

const ass_style_prefix = 'ass_style:'
const ass_event_prefix = 'ass_event:'
const ass_attr_prefix = 'ass_attr:'
const ass_optional_flag = 'ass_optional'

const invalid_section_name = r"--///\__('_')__/\\\--"

struct AssFileParseLine {
pub:
	idx   int
	key   string
	value string
}

struct AssFileParseState {
mut:
	ass_file        AssFile
	current_section string = invalid_section_name
	lines           []AssFileParseLine

	style_formats []string
	event_formats []string
}

fn (mut state AssFileParseState) parse_script_info() ! {
	for line in state.lines {
		mut case_found := false
		$for field in ScriptInfo.fields {
			for attr in field.attrs {
				if attr.starts_with(ass_attr_prefix) {
					key := attr[ass_optional_flag.len..].trim_space().trim('"')
					if line.key == key {
						$if field.typ is string {
							state.ass_file.script_info.$(field.name) = line.value
							case_found = true
						} $else $if field.typ is f64 {
							state.ass_file.script_info.$(field.name) = strconv.atof64(line.value) or {
								return error('${err} - line ${line.idx}')
							}
							case_found = true
						} $else $if field.typ is int {
							state.ass_file.script_info.$(field.name) = strconv.atoi(line.value) or {
								return error('${err} - line ${line.idx}')
							}
							line.value.int()
							case_found = true
						} $else {
							return error('unreachable code detected, detected at line: ${line.idx}')
						}
					}
				}
			}
		}
		if !case_found {
			state.ass_file.script_info.custom_data[line.key] = line.value
		}
	}

	return
}

fn (mut state AssFileParseState) parse_styles() ! {
	if state.lines.len == 0 {
		return error('style tag exists, but contains nothing.')
	}

	format_line := state.lines[0]
	if format_line.key != 'Format' {
		return error('first line of Styles is not a Format, at line ${format_line.idx}')
	}

	state.style_formats.clear()
	for key in format_line.value.split(',') {
		state.style_formats << key.trim_space()
	}

	for line_i in 1 .. state.lines.len {
		style_line := state.lines[line_i]
		mut style := Style {}

		if style_line.key != 'Style' {
			return error("style does not starts with 'Style:' at line ${style_line.idx}")
		}

		style_data := style_line.value.split(',')
		if style_data.len != state.style_formats.len {
			return error("style data count is not equal format data count at line ${style_line.idx}")
		}

		for f_i in 0 .. state.style_formats.len {
			fmt_key := state.style_formats[f_i]
			stl_val := style_data[f_i].trim_space()
			$for field in Style.fields {
				for attr in field.attrs {
					if !attr.starts_with(ass_style_prefix) { continue }

					key_name := attr[ass_style_prefix.len..].trim_space().trim('"')

					if fmt_key != key_name { continue }

					if field.attrs.contains("ass_boolean_int") {
						
					} else if field.attrs.contains("ass_enum_int") {
						
					} else {
						$if field.typ is string {
							style.$(field.name) = stl_val
						}
					}
				}
			}
		}

		state.ass_file.styles << style
	}

	return
}

fn (mut state AssFileParseState) parse_events() ! {
}

fn (mut state AssFileParseState) push_section() ! {
	// state is still empty, skip
	if state.current_section == invalid_section_name { return }

	match state.current_section {
		'Script Info' {
			state.parse_script_info()!
		}
		'V4+ Styles' {
			state.parse_styles()!
		}
		'Events' {
			state.parse_events()!
		}
		else {
			mut contents := map[string]string{}
			for l in state.lines {
				contents[l.key] = l.value
			}
			state.ass_file.custom_sections[state.current_section] = contents.clone()
		}
	}

	state.lines.clear()
	return
}

fn (mut state AssFileParseState) parse_lines(src_main string) !AssFile {
	for a_idx, ut_line in src_main.split_into_lines() {
		idx := a_idx + 1
		line := ut_line.trim_space()

		// skip: empty line and comment
		if line.len == 0 { continue
		 }
		if line.starts_with(';') { continue
		 }
		// section
		if line.starts_with('[') {
			if !line.ends_with(']') {
				return error('section is not closed at line ${idx}')
			}
			state.push_section()!
			state.current_section = line[1..line.len - 1].trim_space()
			continue
		}

		// no state yet, return
		if state.current_section == invalid_section_name {
			return error('a content line is found before a section at line ${idx}')
		}

		// all lines usually have at least one ':' color
		if !line.contains(':') {
			return error('line ${idx} is not a key value pair')
		}

		// content
		ct_key := line.all_before(':')

		if ct_key.contains(',') {
			return error('a comma found in key at line ${idx}')
		}

		ct_value := line.all_after_first(':').trim_space()
		state.lines << AssFileParseLine{
			idx:   idx
			key:   ct_key
			value: ct_value
		}
	}

	state.push_section()!

	return state.ass_file
}

pub fn AssFile.parse(src_main string) !AssFile {
	mut state := AssFileParseState{}
	return state.parse_lines(src_main)!
}
