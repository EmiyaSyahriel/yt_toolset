## Style
this project adheres to V standard code style, but there is some catches:
- velvet language server that I used still hasn't entirely matured yet, there is
  some miss-detection that I have to adhere:
  - "return on option void function" : normally it wasn't needed, V does not enforce it either, but velvet would detect it as "not all code path returns"
  - "structs with int `modif` member": velvet doesn't correctly detect mutable argument modification and proceed that an argument does not need to have mut modifier

## Guideline and Structuring
there is no coding guideline, if it works it works.

as for structure, due to the project is made during a transition period between classic `src/main.v` and `main.v`, we have two `main.v` files.
One for bootstrapping to the new standard on the project root, and the actual main entry in the `src` folder. but most of the logic is located
in the modules directory, which contains the actual tools code, and `src/core`, which contains the tool selector and delegator.

the `sample` directory contains a sample config and data file that should later be mirrored as the config directory. If you run `./build.vsh test_run`,
the program would override the config path to this directory instead of using your machine's actual config directory ( which is the default behaviour
if you run it via the executable directly or via `./build.vsh run -- ...` ).

there would be two additional folder if you use the `build.vsh`, the `.workdir` and `.build`. `.workdir` is for work directory testing, and `.build`,
as you guess it, for build artifacts.
