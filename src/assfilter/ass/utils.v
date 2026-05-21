module ass

import time

pub fn make_ass_time(h i64, m i64, s i64, ms i64) time.Duration {
	return time.Duration((h * time.hour) + (m * time.minute) + (s * time.second) + (ms * 10 * time.millisecond))
}
