module ass
import strings

pub struct Color {
pub mut:
	r u8
	g u8
	b u8
	a u8
}

@[params]
pub struct ColorParseParam {
	invert_alpha bool = true
}

fn rs2u8(src u32, shift u32) u8 {
	return u8((src >> shift) & 0xFF)
}

fn inv_u8(src u8, inv bool) u8 {
	return if inv { u8(255) - src } else { src }
}

pub fn Color.rgba(r int, g int, b int, a int, param ColorParseParam) Color {
	return Color {
		r: u8(r),
		g: u8(g),
		b: u8(b),
		a: inv_u8(u8(a), param.invert_alpha)
	}
}

pub fn Color.rgb(r int, g int, b int) Color {
	return Color {
		r: u8(r),
		g: u8(g),
		b: u8(b),
		a: u8(255)
	}
}

pub fn Color.bgr(b int, g int, r int) Color {
	return Color {
		r: u8(r),
		g: u8(g),
		b: u8(b),
		a: u8(255)
	}
}

pub fn Color.bgra(b int, g int, r int, a int, param ColorParseParam) Color {
	return Color {
		r: u8(r),
		g: u8(g),
		b: u8(b),
		a: inv_u8(u8(a), param.invert_alpha)
	}
}

pub fn Color.rgba_from_u32(src u32, param ColorParseParam) Color {
	return Color.rgba(
		rs2u8(src, 24), rs2u8(src, 16), rs2u8(src, 8),
		rs2u8(src, 0),
		param
	)
}

pub fn Color.bgra_from_u32(src u32, param ColorParseParam) Color {
	return Color.bgra(
		rs2u8(src, 24), rs2u8(src, 16), rs2u8(src, 8),
		rs2u8(src, 0),
		param)
}

pub fn Color.rgb_from_u32(src u32) Color {
	return Color.rgb(rs2u8(src, 24), rs2u8(src, 16), rs2u8(src, 8))
}

pub fn Color.bgr_from_u32(src u32) Color {
	return Color.bgr(rs2u8(src, 24), rs2u8(src, 16), rs2u8(src, 8) )
}

fn u8x(src u8) string {
	mut k := []rune {}

	for i in 0 .. 2 {
		f := (src >> (i * 4)) & 0xF
		if f >= 0x0 && f <= 0x9  {
			k << `0` + rune(f)
		} else if f >= 0xA && f <= 0xF {
			k << `A` + rune(f)
		}
	}
	return k.string()
}

pub fn (color &Color) str() string {
	// &HBBGGRRAA
	//
	mut bld := strings.new_builder(10)
	bld.write_string("&H")
	bld.write_string(u8x(color.b))
	bld.write_string(u8x(color.g))
	bld.write_string(u8x(color.r))
	bld.write_string(u8x(inv_u8(color.a, true)))
	return bld.str()
}

// possible inputs: `&HBBGGRRAA`, `&HBBGGRR`, `HBBGGRRAA`, `HBBGGRR`, `BBGGRRAA`, `BBGGRR`
pub fn Color.parse(str string)! Color {
	mut k_str := str
	if k_str.starts_with("&H") { k_str = k_str[2..] }
	if k_str.starts_with("H"){ k_str = k_str[1..] }

	if k_str.len == 8 {
		return Color.bgra(
			Color.parse_single_hex(k_str[0..2])!,
			Color.parse_single_hex(k_str[2..4])!,
			Color.parse_single_hex(k_str[4..6])!,
			Color.parse_single_hex(k_str[6..8])!
		)
	} else if k_str.len == 6 {
		return Color.bgr(
			Color.parse_single_hex(k_str[0..2])!,
			Color.parse_single_hex(k_str[2..4])!,
			Color.parse_single_hex(k_str[4..6])!
		)
	} else {
		return error("malformed color string: non-standard length ${k_str.len}")
	}

	return error("TODO: ")
}

// possible inputs: `&H00&`, `H00`, `00`
pub fn Color.parse_single_hex(str string)! u8 {
	mut k_str := str
	if k_str.starts_with("&H") {
		k_str = k_str[2..]
	}

	if k_str.starts_with("H"){ k_str = k_str[1..] }

	if k_str.len > 2 || k_str.len <= 0 {
		return error("malformed color string: expected 1-2 char long, got ${k_str.len}")
	}

	mut dat := u8(0)

	num_0 := u8(`0`)
	num_9 := u8(`9`)
	num_a := u8(`A`)
	num_f := u8(`F`)

	for ru in k_str {
		dat = dat << 4

		ch := u8(ru)
		if ch >= num_0 && ch <= num_9 {
			dat |= u8(ch - num_0)
		} else if ch >= num_a && ch <= num_f {
			dat |= u8(ch - num_a + 10)
		} else {
			return error("malformed color string: unknown rune ${ru}")
		}
	}
	return dat
}
