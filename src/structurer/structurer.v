module structurer

import core as c
import os
import utils

pub struct Structurer implements c.ISubTool {
pub mut:
	core &c.Core
	config_root_dir string
	template_root_dir string
	preset_root_dir string
	dry_run bool
}

pub fn (this Structurer) name() string {
	return 'directory'
}

pub fn Structurer.new(core &c.Core) &Structurer {
	mut retval := &Structurer{
		core: core
	}
	retval.config_root_dir = os.join_path(core.config_root_dir, "structure")
	retval.template_root_dir =  os.join_path(retval.config_root_dir, "template")
	retval.preset_root_dir =  os.join_path(retval.config_root_dir, "presets")
	return retval
}

fn (this &Structurer) make_related_dir()! {
	utils.try_mkdir_all(this.template_root_dir)!
	utils.try_mkdir_all(this.preset_root_dir)!

	return
}

pub fn (this Structurer) get_description() string {
	return 'creates structured directory'
}

pub fn (this Structurer) get_help_string() string {
	return 'usage:
ytts directory [flags..] [preset name]

preset name corresponds to a file with .dir extension in ${this.preset_root_dir},
lookup is case-insensitive. please refer to the documentation for the .dir file
specification

flags:
-d, --dry-run          parse dir file, read files, but do not write file
-D, --dep-check        do a dependency check, check if required template file exists, etc.
-l, --list             list all templates

n.b: you cannot merge flag into one like in ls command, all flags have to be separately specified
'
}

fn (this& Structurer) get_preset_file_list() []string {
	this.make_related_dir() or { panic("cannot make system folder: ${err}") }
	return os.walk_ext(this.preset_root_dir, ".dir", hidden: false)
}

fn (this &Structurer) list_all() {
	items := this.get_preset_file_list()
	for i in items {
		_, file_name, _ := os.split_path(i)
		println("- ${file_name}")
	}
}

fn (this &Structurer) find_preset_with_name(name string) !DirFile {
	items := this.get_preset_file_list()

	for i in items {
		if !os.is_file(i) { continue }

		_, file_name, _ := os.split_path(i)
		if file_name.trim_space().to_lower() == name.trim_space().to_lower() {
			file_data := os.read_file(i)!
			return DirFile.parse(file_data)!
		}
	}
	return error("cannot find preset named \"${name}\" - please check ${this.preset_root_dir} if the corresponding ${name}.dir file exists")
}

pub fn (mut this Structurer) execute(args []string) ! {
	if args.contains("--list") || args.contains("-l") {
		this.list_all()
		return
	}

	this.dry_run = args.contains("--dry-run") || args.contains("-d")

	mut preset_name := ""
	for arg in args {
		// flag, skip
		if arg.starts_with("-") { continue }
		preset_name = arg.trim_space()
		break
	}


}
