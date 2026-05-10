module src

import core
import structurer

pub fn main()! {
	mut core_app := core.Core.new()

	core_app.register(core.HelpMan.new(core_app))
	core_app.register(structurer.Structurer.new(core_app))

	core_app.execute(arguments())!
}
