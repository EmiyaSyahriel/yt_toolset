module ass

pub enum BorderStyle {
	outline    = 1
	opaque_box = 3
}

pub enum AlignmentStyle {
	top_left   = 7
	top_center = 8
	top_right  = 9

	center_left   = 4
	center_center = 5
	center_right  = 6

	bottom_left   = 1
	bottom_center = 2
	bottom_right  = 3
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

	// Türkiye, yep
	turkish = 0xA2

	// Vietnam, for the same reason
	vietnamese = 0xA3

	// Hebrew, yes
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
	name string = 'Default' @[ass_style: Name]

	font_name string = 'Roboto' @[ass_style: Fontname]
	font_size u32    = 20    @[ass_style: Fontsize]

	primary_color   Color = Color.rgba(255, 255, 255, 255) @[ass_style: PrimaryColour]
	secondary_color Color = Color.rgba(0, 255, 0, 255) @[ass_style: SecondaryColour]
	outline_color   Color = Color.rgba(0, 0, 0, 255) @[ass_style: OutlineColour]
	back_color      Color = Color.rgba(0, 0, 0, 255) @[ass_style: BackColour]

	bold       bool @[ass_boolean_int; ass_style: Bold]
	italic     bool @[ass_boolean_int; ass_style: Italic]
	underline  bool @[ass_boolean_int; ass_style: Underline]
	strike_out bool @[ass_boolean_int; ass_style: Strikeout]

	scale_x f32 = 100.0 @[ass_style: ScaleX]
	scale_y f32 = 100.0 @[ass_style: ScaleY]
	spacing u32 @[ass_style: Spacing]
	angle   f32 = 0.0 @[ass_style: Angle]

	border_style BorderStyle = .outline @[ass_enum_int: BorderStyle; ass_style: BorderStyle]
	outline      u32         = 1         @[ass_style: Outline]
	shadow       u32         = 2         @[ass_style: Shadow]

	alignment AlignmentStyle = .bottom_center @[ass_enum_int: AlignmentStyle; ass_style: Alignment]
	margin_l  u32            = 10            @[ass_style: MarginL]
	margin_r  u32            = 10            @[ass_style: MarginR]
	margin_v  u32            = 10            @[ass_style: MarginV]

	encoding EncodingCode = .default @[ass_enum_int: EncodingCode; ass_style: Encoding]
}
