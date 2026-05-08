module structurer
import core as c

pub struct Structurer implements c.ISubTool {
pub mut:
	core &c.Core
}

pub fn (this Structurer) name() string { return "directory" }

pub fn Structurer.new(core &c.Core) &Structurer { return &Structurer{ core: core } }

pub fn (this Structurer) get_description() string {
	return "creates structured directory"
}

pub fn (this Structurer) get_help_string() string {
	return ""
}

pub fn (mut this Structurer) execute(args []string)! {
	print("directory")
}
