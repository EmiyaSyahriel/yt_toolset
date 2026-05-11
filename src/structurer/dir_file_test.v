module structurer

fn test_attr_entry() {
	k_key := "Mbg.IsBermanfaat"
	k_value := "false"
	attr_p := AttributeEntry.parse((@LINE).int(), "A ${k_key} = ${k_value}")!
	assert attr_p.key == k_key, "parsed the wrong value in attribute line: key"
	assert attr_p.value == k_value, "parsed the wrong value in attribute line: value"
}

fn test_dir_entry() {
	binturong := "/bin/turong"
	assert DirectoryEntry.parse((@LINE).int(), "D ${binturong}")!.path == binturong, "parsed the wrong value in directory line"
}

fn test_file_entry() {
	source_file := "frieren.elf"
	template_file := "yes_an.elf"
	templated := FileEntry.parse((@LINE).int(), "F ${source_file} :: ${template_file}")!
	assert templated.has_template == true, "parse can't decide does it has template or not, should be yes"
	assert templated.path == source_file, "parsed the wrong value in the file line: path"
	assert templated.template == template_file, "parsed the wrong value in the file line: template"

	non_templated := FileEntry.parse((@LINE).int(), "F ${source_file}")!
	assert non_templated.has_template == false, "parse can't decide does it has template or not, should be no"
	assert non_templated.path == source_file, "parsed the wrong value in the file line: path"
}

fn test_full_parse() {
	dir_path := "/etc/veritas.d"

	attr_k := "Linux.YearOf"
	attr_v := "-1"

	file_fsrc := "Raiden/Shogun.obj"
	file_tmpl := "Raiden/Ei.mtl"

	src := "A ${attr_k} = ${attr_v}
D ${dir_path}
F ${file_fsrc} :: ${file_tmpl}
"
	dir_file := DirFile.parse(src)!
	for item in dir_file.items {
		match item {
			FileEntry {
				assert item.has_template == true, "full parse failed on file entry: has_template"
				assert item.path == file_fsrc, "full parse failed on file entry: source file"
				assert item.template == file_tmpl, "full parse failed on file entry: template path"
			}
			AttributeEntry {
				assert item.key == attr_k, "full parse failed on attribute entry: key"
				assert item.value == attr_v, "full parse failed on attribute entry: value"
			}
			DirectoryEntry {
				assert item.path == dir_path, "full parse failed on directory entry"
			}
			else {
				panic("parser adds unknown type of dir file content item")
			}
		}
	}
}
