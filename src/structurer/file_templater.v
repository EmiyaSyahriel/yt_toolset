module structurer

import strings

interface IFileTemplaterData {}

struct FileString implements IFileTemplaterData {
	text string
}

struct FileKey implements IFileTemplaterData {
	key string
}

const template_open_delim = r"$$("
const template_close_delim = r")$$"

fn (this &Structurer) try_format_template(source string) !(bool, string) {
	mut data := []IFileTemplaterData {}
	mut at := 0

	for at < source.len {
		open_pos := source.index_after(r"$$(", at) or {
			data << FileString { text: source[at..] }
			break
		}

		data << FileString { text: source[at..] }
		key_start := open_pos + template_open_delim.len
		close_pos := source.index_after(template_close_delim, key_start) or {
			return error("unclosed template key starting at ${key_start}")
		}

		next_open := source.index_after(template_open_delim, key_start) or { source.len + 1 }
		if next_open < close_pos {
			return error("detected nested key, which is not supported at ${next_open}")
		}

		data << FileKey { key: source[key_start..close_pos] }

		at = close_pos + template_close_delim.len
	}

	mut has_template := false
	for dat in data {
		if dat is FileKey {
			has_template = true
			break
		}
	}

	if !has_template {
		return false, ""
	}

	mut retval := strings.new_builder(source.len)
	for dat in data {
		match dat {
			FileString {
				retval.write_string(dat.text)
			}
			FileKey {
				key := dat.key.trim_space()
				value := this.get_templater_value(key)!
				retval.write_string(value)
			}
			else { return error("unknown type of template token") }
		}
	}

	return true, retval.str()
}
