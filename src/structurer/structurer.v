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
	dep_check bool
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

	if preset_name == "" {
		return error("preset not found, please specify one in the command line argument")
	}

	this.dep_check = args.contains("--dep-check") || args.contains("-D")

	dir_file := this.find_preset_with_name(preset_name) or { panic(err) }
	this.core.ytts.project.name = preset_name

	if this.dep_check {
		this.do_a_dependency_check(dir_file) or { panic(err) }
	}

	// handle attributes first
	for item in dir_file.items {
		if item is AttributeEntry {
			this.create_attribute(item) or { panic(err) }
		}
	}

	for item in dir_file.items {
		match item {
			FileEntry {
				this.create_file(item) or { panic(err) }
			}
			DirectoryEntry {
				this.create_directory(item) or { panic(err) }
			}
			AttributeEntry{
				// handled previously, skip now
			}
			else {
				return error("unknown item type")
			}
		}
	}

	return

}

fn (this &Structurer) check_dep_file(ent FileEntry)! {
	if !ent.has_template { return }

	template_path := os.join_path(this.template_root_dir, ent.template)

	if !os.exists(template_path) {
		return error("template \"${ent.template}\" not found at \"${template_path}\"")
	}

	return
}

fn (this &Structurer) do_a_dependency_check(file DirFile)! {
	for ent in file.items {
		match ent {
			// we only need to check file entry since only file entry that have dependency
			FileEntry { this.check_dep_file(ent)! }
			else {}
		}
	}
	return
}

fn (this &Structurer) create_attribute(entry AttributeEntry)! {
	// TODO:
}

fn (this &Structurer) create_file(entry FileEntry)! {
	file_path := os.join_path(this.core.work_dir, entry.path)

	if os.exists(file_path) {
		println("file ${file_path} exists, not writing ...")
		return
	}

	if !entry.has_template {
		println("creating file ${file_path} ...")

		if this.dry_run { return }

		mut file := os.create(file_path)!
		defer { file.close() }
		return
	}

	template_path := os.join_path(this.template_root_dir, entry.template)
	if !os.exists(template_path) {
		return error("requested template not found in path ${template_path}")
	}

	data := os.read_file(template_path)!

	is_formatted, formatted_str := this.try_format_template(data)!

	if is_formatted {
		println("creating file \"${file_path}\" by formatting the template from \"${template_path}\" ...")
		if this.dry_run { return }

		os.write_file(file_path, formatted_str)!
	} else {
		println("creating file \"${file_path}\" by directly copying from \"${template_path}\" ...")
		if !this.dry_run { return }

		os.write_file(file_path, data)!
	}

	return
}

fn (this &Structurer) get_templater_value(key string) !string {
	return match key {
		"project.name" { this.core.ytts.project.name }
		"project.path" { os.getwd() }
		"preset.name" { this.core.ytts.project.template }
		else {
			this.core.get_prop_value(key)!
		}
	}
}

fn (this &Structurer) create_directory(entry DirectoryEntry)! {
	// TODO:

	dir_path := os.join_path(this.core.work_dir, entry.path)

	if os.exists(dir_path) {
		println("directory ${dir_path} exists, not creating ...")
		return
	}

	if this.dry_run { return }
	os.mkdir(entry.path)!

	return
}
