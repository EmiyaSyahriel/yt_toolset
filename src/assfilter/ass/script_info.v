module ass

pub struct ScriptInfo {
pub mut:
	custom_data map[string]string
	title       string @[ass_attr: "Title"]
	script_type string @[ass_attr: "ScriptType"]

	original_script      string @[ass_attr: "Original Script"; ass_optional]
	original_editing     string @[ass_attr: "Original Editing"; ass_optional]
	original_translation string @[ass_attr: "Original Translation"; ass_optional]
	original_timing      string @[ass_attr: "Original Timing"; ass_optional]
	synch_point          string @[ass_attr: "Synch Point"; ass_optional]
	script_updated_by    string @[ass_attr: "Script Updated By"; ass_optional]
	update_details       string @[ass_attr: "Update Details"; ass_optional]

	collisions string = "Reverse" @[ass_attr: "Collisions"; ass_optional]
	timer      f64    = 100.0 @[ass_attr: "Timer"; ass_optional]

	wrap_style               string @[ass_attr: "WrapStyle"]
	scaled_border_and_shadow string @[ass_attr: "ScaleBorderAndShadow"]
	ycbcr_matrix             string @[ass_attr: "YCbCr Matrix"]

	play_res_x     int @[ass_attr: "PlayResX"]
	play_res_y     int @[ass_attr: "PlayResY"]
	play_res_depth int @[ass_attr: "PlayDepth"]
}
