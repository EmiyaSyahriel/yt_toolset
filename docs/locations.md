## `$(ConfigDir)` - Config directory path
Overridable by: `$ENV(YTTS_CONFIG_DIR_OVERRIDE)`

Normally located in:
- Linux: `$(XDG_CONFIG_HOME)/emiyasyahriel/yt_toolset`
- Windows: `$(APPDATA)/emiyasyahriel/yt_toolset`

## `$(WorkDir)` - Current work directory path
Overridable by: `$ENV(YTTS_WORK_DIR_OVERRIDE)` → `$ENV(YTTS_WORKDIR_OVERRIDE)`

Normally located in current directory where you invoke the command, both
on Windows and Linux
