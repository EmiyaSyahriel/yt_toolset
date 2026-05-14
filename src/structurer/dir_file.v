module structurer

pub interface IDirEntry {}

pub struct DirectoryEntry implements IDirEntry {
pub mut:
	path string
}

fn DirectoryEntry.parse(idx int, src string) !DirectoryEntry {
	_ = idx

	retval := DirectoryEntry{
		path: src[2..].trim_space()
	}

	return retval
}

pub struct FileEntry implements IDirEntry {
pub mut:
	path         string
	has_template bool
	template     string
}

fn FileEntry.parse(idx int, src string) !FileEntry {
	core := src[2..].trim_space().split('::') as []string

	if core.len != 1 && core.len != 2 {
		return error('malformed file entry at line ${idx}')
	}

	has_temp := core.len == 2
	path := core[0].trim_space()
	templ_path := if has_temp { core[1].trim_space() } else { '' }

	retval := FileEntry{
		path:         path
		has_template: has_temp
		template:     templ_path
	}
	return retval
}

pub struct AttributeEntry implements IDirEntry {
pub mut:
	key   string
	value string
}

fn AttributeEntry.parse(idx int, src string) !AttributeEntry {
	core := src[2..].trim_space().split('=') as []string
	if core.len != 2 {
		return error('malformed attribute entry at line ${idx}')
	}

	retval := AttributeEntry{
		key:   core[0].trim_space()
		value: core[1].trim_space()
	}

	return retval
}

pub struct DirFile {
pub mut:
	items []IDirEntry
}

pub fn DirFile.parse(src string) !DirFile {
	lines := src.split_into_lines()
	mut items := []IDirEntry{}
	mut idx := 0
	for r_line in lines {
		line := r_line.trim_space()
		idx++
		match true {
			line.starts_with('D ') {
				items << DirectoryEntry.parse(idx, line)!
			}
			line.starts_with('F ') {
				items << FileEntry.parse(idx, line)!
			}
			line.starts_with('A ') {
				items << AttributeEntry.parse(idx, line)!
			}
			line.starts_with("#") || line.starts_with("//") {
				// comment
				continue
			}
			line.len <= 0 {
				continue
			}
			else {
				return error('dir file invalid line format ${idx}: ${line} ')
			}
		}
	}

	retval := DirFile{
		items: items
	}
	return retval
}
