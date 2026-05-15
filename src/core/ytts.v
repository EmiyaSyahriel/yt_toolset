module core

import toml

pub struct YttsFileProject {
pub mut:
	template string
	name string
	created_at toml.DateTime
	render_dir string
	thumb_dir string
	project_dir string
	src_dir_stable string
	src_dir_record string
	scratch_dir string
}

pub struct YttsFile {
pub mut:
	project YttsFileProject
}

pub fn YttsFile.read(src string) !YttsFile {
	return toml.decode[YttsFile](src)
}

pub fn (this YttsFile) str() string {
	return toml.encode[YttsFile](this)
}
