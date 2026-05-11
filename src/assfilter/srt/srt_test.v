module srt

import time

fn hh_mm_ss_mss(h int, m int, s int, ms int) time.Duration {
	return (h * time.hour) +
		(m * time.minute) +
		(s * time.second) +
		(ms * time.millisecond)
}

fn test_parse_time() {
	assert parse_srt_time(0, "05:03:10.100")! == hh_mm_ss_mss(5, 3, 10, 100), "dot-decimal format does not work"
	assert parse_srt_time(0, "05:03:10,100")! == hh_mm_ss_mss(5, 3, 10, 100), "comma-decimal format does not work"
	assert parse_srt_time(0, "05:03:10")! == hh_mm_ss_mss(5, 3, 10, 0), "hh:mm:ss does not work"
	assert parse_srt_time(0, "03:10.100")! == hh_mm_ss_mss(0, 3, 10, 100), "mm:ss.mss does not work"
	assert parse_srt_time(0, "03:10,100")! == hh_mm_ss_mss(0, 3, 10, 100), "mm:ss,mss does not work"
	assert parse_srt_time(0, "03:10")! == hh_mm_ss_mss(0, 3, 10, 0), "mm:ss does not work"
}
