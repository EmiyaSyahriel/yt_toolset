#!/usr/bin/env -S v -raw-vsh-tmp-prefix .__make run
import syvmake

mut ctx := syvmake.context()
ctx.add_executable(
    name: "yt_toolset"
    root_dir: "."
)!
ctx.exec()!
