module core

@[heap]
pub struct ISubToolWrap {
pub mut:
	name string
	tool &ISubTool
}

pub fn ISubToolWrap.wrap(name string, inner &ISubTool) &ISubToolWrap {
	return &ISubToolWrap { name: name, tool: inner }
}

@[heap]
pub struct Core {
pub mut:
	subtools []&ISubToolWrap
}

pub fn Core.new() &Core {
	mut core := &Core {
		subtools: []
	}

	return core
}

pub fn (mut this Core) register(ins &ISubTool) {
	this.subtools << ISubToolWrap.wrap(ins.name(), ins)
}

pub fn (this &Core) find_tool_by_name(name string) !&ISubToolWrap {
	for st in this.subtools {
		if st.name != name { continue }
		return st
	}

	return error("unknown tool: ${name}")
}

pub fn (this &Core) find_tool_by_type[T]() !&ISubToolWrap {
	for _, tool in this.subtools {
		if tool.tool !is &T { continue }
		return tool
	}
	return error("unknown requested type")
}

pub fn (mut this Core) execute(args []string)! {

	usable_arg := args[1..]

	contains_help := args.contains("--help") || args.contains("-h")
	if usable_arg.len == 0 || contains_help {
		mut t := this.find_tool_by_name("help")!
		t.tool.execute([])!
		return
	}

	mut tool := this.find_tool_by_name(usable_arg[0])!
	tool_arg := usable_arg[1..]
	tool.tool.execute(tool_arg)!
}
