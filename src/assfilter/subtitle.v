module assfilter

import core as c
import ass
import srt as _
import ytt as _

pub enum SubFormat {
	none
	srt
	ytt
	ass
	lrc
}

pub struct Subtitler implements c.ISubTool {
pub mut:
	core &c.Core
	export_format SubFormat = .none
}

pub fn (this Subtitler) name() string {
	return 'subtitler'
}

pub fn (this Subtitler) get_description() string {
	return 'do subtitle filtering'
}

pub fn (this Subtitler) get_help_string() string {
	return 'usage:
ytts subtitler [flags..] [name] [language]

this script would find [name].ass in \$(project.render_dir) and then proceed to
filter out languages. If no name is specified, then will use \$(project.name).ass
instead

this would also apply text line formatting based on name table.

flags:
-f, --format [fmt]	which format to export
-n, --no-name		do not format names, just leave the line as-is

supported exported formats:
srt					SubRip
ytt					YouTube SRV3
ass					Advanced Substation Alpha
lrc					Lyric File
'
}

pub fn (mut this Subtitler) execute(args []string) ! {
	return
}

pub fn Subtitler.new(core &c.Core) &Subtitler {
	mut retval := &Subtitler{
		core: core
	}

	return retval
}
