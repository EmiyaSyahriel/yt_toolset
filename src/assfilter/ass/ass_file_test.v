module ass

import time

fn prepare_your_ass() AssFile {
	info := ScriptInfo{
		title:                    'Genshin Impact'
		script_type:              'v4.00+'
		wrap_style:               '0'
		scaled_border_and_shadow: 'yes'
		ycbcr_matrix:             'PC.709'
		play_res_x:               1280
		play_res_y:               720
	}

	mut custom_sections := map[string]map[string]string{}

	mut aegisub := map[string]string{}
	aegisub['Audio File'] = 'C:\\home\\Bagong\\Videos\\Bad Apple.pcm_s16le'
	aegisub['Video File'] = 'C:\\home\\Bagong\\Videos\\Bad Apple.h264'
	aegisub['Video AR Mode'] = '4'
	aegisub['Video AR Value'] = '1.777778'
	aegisub['Video Zoom Percent'] = '0.5000000'
	aegisub['Active Line'] = '1'
	aegisub['Video Position'] = '102'

	custom_sections['Aegisub Project Garbage'] = aegisub.clone()

	mut styles := []Style{}

	styles << Style {}

	styles << Style {
		name: "Karaoke - OP Romaji"
		font_name: "CaskaydiaCove NF"
		font_size: 38

		primary_color: Color.rgba_from_u32(0x0099FFFF)
		secondary_color: Color.rgba_from_u32(0x9900FF44)
		outline_color: Color.rgba_from_u32(0xFFFFFF00)
		back_color: Color.rgba_from_u32(0x00000000)

		margin_v: 50
		alignment: .top_center

		bold: true
	}

	styles << Style {
		name: "Karaoke - OP Indonesia"
		font_name: "CaskaydiaCove NF"
		font_size: 38

		primary_color: Color.rgba_from_u32(0x0099FFFF)
		outline_color: Color.rgba_from_u32(0x00000088)

		outline: 1
		border_style: .opaque_box
	}

	mut events := []Event{}

	events << Event{
		layer:      0
		start_time: 1200 * time.millisecond
		end_time:   1521 * time.millisecond
		kind:       .dialogue
		text:       'Kanaerareru tokino minoru demo kedarusaga hora kuru kuru herta sama'
	}

	events << Event{
		layer:      0
		start_time: 62330 * time.millisecond
		end_time:   67321 * time.millisecond
		kind:       .dialogue
		text:       'Kana-shimpu nante:
tsukarete dake yo'
	}

	events << Event{
		layer:      0
		start_time: 62330 * time.millisecond
		end_time:   67321 * time.millisecond
		kind:       .comment
		effect:		'template syl'
		text:       '{\\move(\${x-100}, \$y, \$x, \$y, 0, 500)\\fade(0, 500, 0, 1)}'
	}

	retval := AssFile{
		script_info:     info
		events:          events
		styles:          styles
		custom_sections: custom_sections
	}

	return retval
}

fn test_ass_file_tostring() {
	ass_file := prepare_your_ass()
	println(ass_file.str())
}
