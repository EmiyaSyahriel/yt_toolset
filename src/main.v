module src

import core
import structurer
import assfilter

pub fn main()! {
	mut core_app := core.Core.new()


	core_app.mkdir_all_related_directories() or { panic(err) }
	core_app.register(core.HelpMan.new(core_app))
	core_app.register(structurer.Structurer.new(core_app))
	core_app.register(assfilter.Subtitler.new(core_app))

	core_app.execute(arguments())!
}
