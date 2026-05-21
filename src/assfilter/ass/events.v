module ass

import time

pub enum EventKind {
	none
	dialogue  @[display_name: "Dialogue"]
	comment   @[display_name: "Comment"]
	// Anything beyond this is rarely supported
	picture  @[display_name: "Picture"]
	sound    @[display_name: "Sound"]
	movie    @[display_name: "Movie"]
	command  @[display_name: "Command"]
}

const ass_style_display_name_prefix = "display_name:"

pub fn EventKind.from_string(source string) EventKind {
	$for val in EventKind.values {
		for attr in val.attrs {
			if !attr.starts_with(ass_style_display_name_prefix) {
				continue
			}

			key := attr[ass_style_display_name_prefix.len..].trim_space().trim('"')
			if key != source {
				continue
			}

			return EventKind(val.value)
		}
	}
	return EventKind.none
}

pub fn (kind EventKind) str() string {

	$for item in EventKind.values {
		if item.value == kind {
			for attr in item.attrs {
				if !attr.starts_with(ass_style_display_name_prefix) {
					continue
				}

				value := attr[ass_style_display_name_prefix.len..]
				return value.trim_space().trim('"')
			}
		}
	}
	return 'None'
}

pub struct Event {
pub mut:
	kind       EventKind
	layer      int           @[ass_event: "Layer"]
	start_time time.Duration = 0 * time.millisecond @[ass_event: "Start"; ass_time]
	end_time   time.Duration = 1 * time.millisecond @[ass_event: "End"; ass_time]
	style      string        = 'Default'        @[ass_event: "Style"]
	actor_name string        @[ass_event: "Name"]
	margin_l   int           @[ass_event: "MarginL"]
	margin_r   int           @[ass_event: "MarginR"]
	margin_v   int           @[ass_event: "MarginV"]
	effect     string        @[ass_event: "Effect"]
	text       string        @[ass_event: "Text"]
}

pub fn (this &Event) is_valid() bool {
	return this.start_time <= this.end_time
}

pub fn (this &Event) ignore_this_one() bool {
	// we don't support other than dialogue :|
	return this.kind != .dialogue
}
