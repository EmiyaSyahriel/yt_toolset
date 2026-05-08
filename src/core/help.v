module core

import strings
import os

pub struct HelpMan implements ISubTool {
mut:
	core &Core
}

pub fn HelpMan.new(core &Core) &HelpMan { return &HelpMan{ core: core } }

pub fn (this HelpMan) name() string { return "help" }

pub fn (this HelpMan) get_description() string {
	return "print help of specific subtool"
}

pub fn (this HelpMan) get_help_string() string {
	return "usages:
- ytts help
- ytts help [tool name]

if no tool name is specified, print short descriptions of available commands
"
}

pub fn HelpMan.do_something() {

	}

fn (this HelpMan) print_all() {
	mut max_title_len := 10
	for tool in this.core.subtools {
		max_title_len = if tool.name.len > max_title_len + 5 { tool.name.len } else { max_title_len + 5 }
	}

	mut strbuild := strings.new_builder(100)
	prog_path := arguments()[0]
	_, prog_name, _ := os.split_path(prog_path)
	strbuild.write_string2("usage", "\n")
	strbuild.write_string2("    ${prog_name} [subtool] [... subtool parameters]", "\n\n")
	strbuild.write_string2("subtools: ", "\n")

	for tool in this.core.subtools {
		pad_len := max_title_len - tool.name.len
		strbuild.write_string("    ")
		strbuild.write_string(tool.name)
		strbuild.write_repeated_rune(` `, pad_len)
		strbuild.write_string(tool.tool.get_description())
		strbuild.writeln("")
	}
	println(strbuild)
}

// usage: ytts help
// or
// ytts help [tool]
pub fn (mut this HelpMan) execute(args []string) ! {
	if args.len == 0 {
		this.print_all()
		return
	}

	tool_name := args[0]
	tool := this.core.find_tool_by_name(tool_name)!
	println(tool.tool.get_help_string())
}
