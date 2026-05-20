module ass

pub struct ScriptInfo {
pub mut:
	custom_data              map[string]string
	title                    string @[ass_attr: "Title"]
	script_type              string @[ass_attr: "ScriptType"]
	wrap_style               string @[ass_attr: "WrapStyle"]
	scaled_border_and_shadow string @[ass_attr: "ScaleBorderAndShadow"]
	ycbcr_matrix             string @[ass_attr: "YCbCr Matrix"]
	play_res_x               int    @[ass_attr: "PlayResX"]
	play_res_y               int    @[ass_attr: "PlayResY"]
}
