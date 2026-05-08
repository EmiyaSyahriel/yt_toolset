module ass

fn test_color_parser_single_hex() {
	assert Color.parse_single_hex("3F")! == 0x3F, "simple hex failed"
	assert Color.parse_single_hex("H87")! == 0x87, "just H-prefix failed"
	assert Color.parse_single_hex("&H67")! == 0x67, "&H-prefix failed"
}

fn test_color_parser() {
	assert Color.parse("0099FF")! == Color.bgr(0x00, 0x99, 0xFF), "BBGGRR failed"
	assert Color.parse("HCAC0C1")! == Color.bgr(0xCA, 0xC0, 0xC1), "just H-prefix BBGGRR failed"
	assert Color.parse("&H0099FF")! == Color.bgr(0x00, 0x99, 0xFF), "&H-prefix BBGGRR failed"

	assert Color.parse("0099FFAA")! == Color.bgra(0x00, 0x99, 0xFF, 0xAA), "BBGGRRAA failed"
	assert Color.parse("H0099FFAA")! == Color.bgra(0x00, 0x99, 0xFF, 0xAA), "just H-prefix BBGGRRAA failed"
	assert Color.parse("&H0099FFAA")! == Color.bgra(0x00, 0x99, 0xFF, 0xAA), "&H-prefix BBGGRRAA failed"
}
