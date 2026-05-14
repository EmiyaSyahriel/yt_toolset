module core

import os
import utils

@[heap]
pub struct ISubToolWrap {
pub mut:
	name string
	tool &ISubTool
}

pub fn ISubToolWrap.wrap(name string, inner &ISubTool) &ISubToolWrap {
	return &ISubToolWrap{
		name: name
		tool: inner
	}
}

@[heap]
pub struct Core {
pub mut:
	subtools []&ISubToolWrap
	config_root_dir string
	work_dir string
}

pub fn Core.new() &Core {
	mut core := &Core{
		subtools: []
	}

	core.get_dirs()

	return core
}

pub fn (core Core) mkdir_all_related_directories()! {
	utils.try_mkdir_all(core.config_root_dir)!
}

fn (mut core Core) get_config_dir()! {
	core.config_root_dir = os.getenv_opt("YTTS_CONFIG_DIR_OVERRIDE") or {
		os.join_path(os.config_dir()!, "emiyasyahriel", "yt_toolset")
	}

}

fn (mut core Core) get_workdir() {
	core.work_dir = os.getenv_opt("YTTS_WORK_DIR_OVERRIDE") or {
		os.getenv_opt("YTTS_WORKDIR_OVERRIDE") or {
			os.getwd()
		}
	}
}

fn (mut core Core) get_dirs() {
	core.get_config_dir() or { panic(err) }
	core.get_workdir()
}

pub fn (mut this Core) register(ins &ISubTool) {
	this.subtools << ISubToolWrap.wrap(ins.name(), ins)
}

pub fn (this &Core) find_tool_by_name(name string) !&ISubToolWrap {
	for st in this.subtools {
		if st.name != name { continue
		 }
		return st
	}

	return error('unknown tool: ${name}')
}

pub fn (this &Core) find_tool_by_type[T]() !&ISubToolWrap {
	for _, tool in this.subtools {
		if tool.tool !is &T { continue
		 }
		return tool
	}
	return error('unknown requested type')
}

pub fn (mut this Core) execute(args []string) ! {
	usable_arg := args[1..]

	contains_help := args.contains('--help') || args.contains('-h')
	if usable_arg.len == 0 || contains_help {
		mut t := this.find_tool_by_name('help')!
		t.tool.execute([])!
		return
	}

	mut tool := this.find_tool_by_name(usable_arg[0])!
	tool_arg := usable_arg[1..]
	tool.tool.execute(tool_arg)!
}
