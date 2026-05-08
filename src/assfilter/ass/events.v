module ass
import time

pub enum EventKind {
	dialogue
	comment
	picture
	sound
	movie
	command
}

pub struct Event {
pub mut:
	kind EventKind
	layer int = 0
	start_time time.Duration = 0 * time.millisecond
	end_time time.Duration = 1 * time.millisecond
	style string = "Default"
	actor_name string = ""
	margin_l int = 0
	margin_r int = 0
	margin_v int = 0
	effect string = ""
	text string = ""
}

pub fn (this &Event) is_valid() bool {
	return this.start_time
}

pub fn (this &Event) ignore_this_one() bool {
	// we don't support other than dialogue :|
	return this.kind != dialogue
}
