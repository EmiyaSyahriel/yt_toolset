module utils

import os
pub fn try_mkdir_all(path string)! {
	if os.exists(path) { return }

	os.mkdir_all(path)!

	// velvet-ls formalism
	return
}
