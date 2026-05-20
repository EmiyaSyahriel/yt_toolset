module ass

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
