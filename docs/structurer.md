# Structurer ( `directory` )
Create project directory structure

Usage:
```bash
ytts directory [preset] [flags]
```
Example:
```bash
ytts directory mltd_tanjoubi
```

It would find a matching preset file in this `$(ConfigDir)/structure/presets/$(PresetName).dir`
format path ( name is case-insensitive ) and then proceed to create the directory structure

## `*.dir` file
It is just a simple text-based file structure descriptor, processed line-by-line top-to-bottom

- Empty line would be ignored
- Anything starts with `#` or `//` is a comment, therefore also ignored
- `D` line starter means to create a directory
    - V's `mkdir_all` will handle the rest, no need to specify each part first
- `F` line starter means to create a file
    - It creates empty file by default
    - If is followed by `:: $(file_name)`, then it would read a template from
     `$(ConfigDir)/structure/template/$(file_name)`, reformat it if formatting
      sign found and then write it to the select path
- `A` line starter means attribute, being filled into the `ytts.toml`

anything inside of `$()` will be substituted, see `ytts.toml` section below

## `ytts.toml` file
It contains the project metadata & properties:
- `project` - Project Configuration Namespace
  - `template` - What template is being used
  - `name` - Name of the project ( from `getwd()` base file name, or else `$ENV(YTTS_FILE_NAME)` )
  - `created_at` - When the project is created ( in ISO Date Format )
  - `render_dir` - Render directory
  - `thumb_dir` - Thumbnail directory
  - `project_dir` - Editing program project directory ( Kdenlive, etc. )
  - `src_dir_stable` - Stable source files directory
  - `src_dir_record` - Recording output directory
  - `scratch_dir` - By default, it was `$(PWD)/.ytts/`

## Template file
If a template file contains this notation: `$$(key)$$`, it would be considered formattable
template file, in which the `$$(key)$$` would be replaced with appropriate values:
- `project.name` - Project name, taken from `ytts.toml#project.name`
- `project.path` - Project path, full `getwd()`
- `preset.name` - Requested preset name
- The rest of `ytts.toml` ...

Otherwise it is copied as-is.
