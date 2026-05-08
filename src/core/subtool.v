module core

pub interface ISubTool {
	name() string
	get_description() string
	get_help_string() string
mut:
	core &Core
	// this would send just the environment
	execute(args []string)!
}
