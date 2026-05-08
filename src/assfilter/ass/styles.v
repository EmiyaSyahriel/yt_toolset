module ass

pub enum BorderStyle {
	outline = 1
	opaque_box = 3
}

pub enum AlignmentStyle {
	top_left = 7
	top_center = 8
	top_right = 9

	center_left = 4
	center_center = 5
	center_right = 6

	bottom_left = 1
	bottom_center = 2
	bottom_right = 3
}

//
pub enum EncodingCode {
	// 8-bit ANSI English
	ansi = 0x00

	// Current System Locale
	default = 0x01

	// Symbols
	symbol = 0x02

	// Apple Macintosh
	mac = 0x4D

	// Japanese Shift-JIS
	shift_jis = 0x80

	// Korean Hangeul
	hangeul = 0x81

	// Korean Johab
	johab = 0x82

	// Simplified Chinese GB2313
	gb2312 = 0x86

	// Traditional Chinese BIG5
	big5 = 0x88

	// Greek, yes
	greek = 0xA1

	// Tukiye, yep
	turkish = 0xA2

	// Vietnam, for the same reason
	vietnamese = 0xA3

	// Hebrew, no comment or I would get anti-semitic false accusation
	hebrew = 0xB1

	// Arabic, na'am
	arabic = 0xB2

	// Northeastern Europe - Baltic Countries
	baltic = 0xBA

	// Russian, in case you don't know
	russian = 0xCC

	// Thailand
	thai = 0xDE

	// Eastern European
	east_european = 0xEE

	// Depending on System-Specific Locale
	oem = 0xFF
}

pub struct Style {
pub mut:
	name string
	font_name string
	font_size u32
	primary_color Color
	secondary_color Color
	outline_color Color
	back_color Color
	bold bool
	italic bool
	underline bool
	strike_out bool
	scale_x f32
	scale_y f32
	spacing u32
	angle f32
	border_style BorderStyle
	outline u32
	shadow u32
	alignment AlignmentStyle
	margin_l u32
	margin_r u32
	margin_v u32
	encoding EncodingCode
}
