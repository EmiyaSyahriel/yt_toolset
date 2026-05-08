#!/usr/bin/env -S v -raw-vsh-tmp-prefix __build_vsh__ run
import build

const args := arguments()
const root_build_dir := abs_path(".build")
const is_prod := args.contains("-prod")
const is_transpiles := args.contains("-src")
const is_tryhard := is_prod && args.contains("-tryhard")
const build_dir := join_path(root_build_dir, if is_tryhard { "tryhard" } else if is_prod { "prod" } else { "dev" })
const bin_path := join_path(build_dir, "ytts")

fn execsh(name string, cwd string, args []string, env map[string]string)! {
    exe_path := if is_abs_path(name) { name } else { find_abs_path_of_executable(name)! }

    if !exists(exe_path) {
        return error("executable not found: ${name}")
    }

    mut m_env := environ()
    for k,v in env {
        if v.len == 0 {
            m_env.delete(k)
            continue
        }

        m_env[k] = v
    }

    mut proc := new_process(exe_path)
    proc.set_environment(m_env)
    proc.set_args(args)
    proc.set_work_folder(cwd)
    proc.run()
    proc.wait()

    if proc.code != 0 {
        return error("${name} exists with code ${proc.code}")
    }
}

fn is_build_expired(name string, sources []string) bool {
    if !exists(name) { return true }

    bin_time := file_last_mod_unix(name)
    for source in sources {
        if !exists(source) { continue }
        src_time := file_last_mod_unix(source)
        // this one changed, ok
        if bin_time < src_time {
            return true
        }
    }

    return false
}

fn build_main(_ build.Task) ! {
    mut f_args := ["."]

    if is_transpiles {
        f_args << ["-o", "${bin_path}.c"]
    } else {
        f_args << ["-o", bin_path]
    }

    if is_prod {
        f_args << "-prod"
        f_args << ["-cc", "clang"]

        if exists_in_system_path("upx") {
            f_args << "-compress"
        }

        if is_tryhard {
            f_args << ["-fast-math"]
            f_args << ["-d", "no_segfault_handler"]
            f_args << ["-cflags", "-march=native"]
        }
    } else {
        f_args << "-g"
        f_args << ["-cc", "gcc"]
    }


    execsh("v", getwd(), f_args, {})!
}

fn should_rebuild_main(_ build.Task) !bool {
    sources := walk_ext("./src", "v", hidden: false)
    return is_build_expired(if is_transpiles { "${bin_path}.c" } else { bin_path }, sources)
}

fn run_main(_ build.Task) ! {
    arg_idx := args.index("--")
    add_args := if arg_idx > -1 && (arg_idx + 1) < args.len { args[(arg_idx + 1)..] } else  { []string{} }
    execsh(bin_path, abs_path("testdir"), add_args, {})!
    exit(0)
}

mut ctx := build.context(default: "build")

ctx.task(name: 'build', run: build_main, should_run: should_rebuild_main)
ctx.task(name: 'run', run: run_main, depends: [ 'build' ])

ctx.run()
