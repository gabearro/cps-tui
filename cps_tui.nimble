version = "1.0.1"
author = "Gabriel Arroyo"
description = "Declarative terminal UI framework for the CPS Nim runtime."
license = "MIT"
srcDir = "src"
skipDirs = @["tests", "examples", "benchmarks", ".github", "scripts"]

requires "nim >= 2.0.0"
requires "https://github.com/gabearro/cps-runtime == 1.1.1"

task test, "Run the project test suite":
  exec "nim c -r tests/tui/test_tui_core.nim"
  exec "nim c -r tests/tui/test_tui_components.nim"
  exec "nim c -r tests/tui/test_tui_events.nim"
  exec "nim c -r tests/tui/test_splitview_drag.nim"

task testMms, "Run TUI under ARC, ORC, and AtomicARC":
  for mm in ["arc", "orc", "atomicArc"]:
    exec "nim c -r --threads:on --mm:" & mm & " tests/tui/test_tui_core.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/tui/test_tui_components.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/tui/test_tui_events.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/tui/test_splitview_drag.nim"
