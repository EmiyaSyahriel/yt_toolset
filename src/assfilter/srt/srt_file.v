module srt

import time
import strings

pub struct SrtLine {
pub mut:
	index int
	start time.Duration
	end   time.Duration
	text  string
}

pub struct SrtFile {
pub mut:
	lines []SrtLine
}

struct SrtParserState {
pub mut:
	idx  string
	time string
	text strings.Builder
}

struct TimeValidator {
pub:
	index int
pub mut:
	max int
}

fn (this TimeValidator) v(src_s string, what string)! int {
	src := src_s.trim_space().int()
	if src >= this.max { return error("${what} ${src} is higher than ${this.max} at index ${this.index}") }
	return src
}

const valid_timer_line_syms := [':', '.', ',', '-->']

fn parse_srt_time(idx int, src string)! time.Duration {
	fmt_times := src.trim_space().split_any(":.,")
	mut tv := TimeValidator { index: idx }
	// we supported hh:mm:ss, mm:ss, hh:mm:ss.mss, mm:ss.mss
	if fmt_times.len == 4 { // canonical format hh:mm:ss.mss
		tv.max = 9999
		h := tv.v(fmt_times[0], "hour")! * time.hour
		tv.max = 60
		m := tv.v(fmt_times[1], "minute")! * time.minute
		s := tv.v(fmt_times[2], "second")! * time.second
		tv.max = 1000
		ms := tv.v(fmt_times[3], "millisecond")! * time.millisecond

		return h + m + s + ms
	} else if fmt_times.len == 3 {
		last_idx := fmt_times.len - 1
		if fmt_times[last_idx].len == 3 { // mm:ss.mss format
			tv.max = 60
			m :=  tv.v(fmt_times[0], "minute")! * time.minute
			s :=  tv.v(fmt_times[1], "second")! * time.second
			tv.max = 1000
			ms := tv.v(fmt_times[2], "millisecond")! * time.millisecond

			return m + s + ms
		} else if fmt_times[last_idx].len == 2 { // hh:mm:ss format
			tv.max = 60
			h := tv.v(fmt_times[0], "hour")! * time.hour
			m := tv.v(fmt_times[1], "minute")! * time.minute
			tv.max = 1000
			s := tv.v(fmt_times[2], "second")! * time.second

			return h + m + s
		}
	} else if fmt_times.len == 2 { // mm:ss format
		tv.max = 60
		m := tv.v(fmt_times[0], "minute")! * time.minute
		s := tv.v(fmt_times[1], "second")! * time.second

		return m + s
	}

	return error("srt format error at line ${idx}: timestamp consists of non-supported number of time part ${fmt_times.len}")
}

fn (mut pstate SrtParserState) parse_self_and_clear()! SrtLine {
	index := pstate.idx.int()
	time_line := pstate.time.trim_space()

	mut time_code := if time_line.starts_with("[") { // some older and weird format with [ start --> end ] format
		if time_line.ends_with("]") {
			time_line[1..time_line.len - 2]
		} else {
			time_line[1..time_line.len - 1]
		}
	} else {
		time_line
	}
	time_format_line := time_code.split("-->")

	if time_format_line.len != 2 {
		return error("srt format error at ${index}: timestamp consist of ${time_format_line} time point instead of 2")
	}

	time_start := parse_srt_time(index, time_format_line[0])!
	time_end := parse_srt_time(index, time_format_line[1])!

	text := pstate.text.str().trim_space()

	pstate.idx = ''
	pstate.time = ''
	pstate.text.clear()

	return SrtLine {
		index: index
		start: time_start
		end: time_end
		text: text
	}
}

pub fn SrtFile.parse(src string) !SrtFile {
	mut content := []SrtLine{}

	mut pstate := SrtParserState{}

	// phase 1
	lines := src.split_into_lines()

	mut idx := 0
	for idx = 0; idx < lines.len - 1; idx++ {
		c_line := lines[idx].trim_space()
		n_line := lines[idx + 1].trim_space()

		timer_line_check_state := fn [n_line](x string) bool { return n_line.contains(x) }

		if c_line.is_int() && valid_timer_line_syms.all(timer_line_check_state) {
			if pstate.idx != '' {
				content << pstate.parse_self_and_clear()!
			}

			pstate.idx = c_line
			pstate.time = n_line
			idx++
			continue
		}

		// empty line and next line is something, skip inputting this one
		if c_line.len == 0 && n_line.is_int() {
			continue
		}

		pstate.text.write_string2(c_line, "\n")

	}

	retval := SrtFile{ lines: content }
	return retval
}
