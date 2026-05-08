module ass

pub struct AssFile {
pub mut:
	script_info ScriptInfo
	styles []Style
	custom_sections map[string]map[string]string
}
