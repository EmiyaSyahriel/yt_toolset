module core

fn test_core_config_dir() {
	core := Core.new()
	println("Root Config Directory: ${core.config_root_dir}")
}
