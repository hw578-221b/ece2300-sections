# ECE2300 Formatting Tool Documentation

Author: Anthony Song

Date: 08/14/2026

## What this Tool Does

This tool is a custom formatter for ECE2300. It formats SystemVerilog files to
match the class's coding conventions. The formatter runs in two passes: it first
runs ECE 2300 prechecks and Verible linting, then autoformats the file with
Verible. The file is overwritten in place.

If linting fails, the formatter prints the error and stops before the autoformat
pass. One precheck does write to the file before that point: runs of two or more
blank lines are collapsed down to one. Nothing else is touched, so a file that
fails lint is otherwise exactly as you wrote it. Please report any bugs, issues,
or feedback to Professor Batten.

## Setup

Setup is one thing: get a build of the ECE 2300 Verible fork onto your `PATH`.
The tool resolves both binaries at runtime with `shutil.which()`, so there is
nothing to edit in the source. Everything below assumes Linux x86-64 (ecelinux
or the devcontainer), since the Verible binaries are ELF executables.

**Step 1 — put the fork on `PATH`.**

Once Verible ships with the class environment, this is all it takes:

```
% source setup-ece2300.sh
% which verible-verilog-format
```

That prints something like `/classes/ece2300/.../bin/verible-verilog-format`,
and setup is done. If `which` comes up empty, the class install does not exist
yet on that machine and you need your own build — see
[Building the fork yourself](#building-the-fork-yourself), then prepend that
install directory yourself:

```
% export PATH=<install-dir>:$PATH
```

**Step 2 — confirm both binaries are the fork, not upstream.**

```
% verible-verilog-lint --version
% verible-verilog-format --version
```

Both must print `Version head`. If either prints a release string such as
`v0.0-4051-g9fdb4057`, that one is stock upstream and will not produce class
style. Check this whenever `PATH` changes, because a mismatched pair fails
silently: lint still behaves, formatting just quietly comes out wrong.

**Step 3 — confirm the scripts resolve the same binaries.**

```
% cd <repo>/scripts/format
% python3 -c "from format_utils import find_verible_lint, find_verible_format; \
print(find_verible_lint('setup')); print(find_verible_format('setup'))"
```

Both lines must print an absolute path, and they must match what `which`
printed in Step 1. If a binary is missing, this exits with
`setup: Error: verible-verilog-format not found on PATH.` instead.

**Step 4 — format a real file to prove the pipeline runs end to end.**

The formatter overwrites in place and refuses to touch anything that is not
committed, so run it on a clean file inside the repo rather than on a copy in
`/tmp`:

```
% cd <repo>
% git status --porcelain lab2/FullAdder_GL.v   # must print nothing
% ./scripts/ece2300-format lab2/FullAdder_GL.v
% git diff lab2/FullAdder_GL.v                 # review, then undo if you like
% git checkout -- lab2/FullAdder_GL.v
```

A file that still has its instructor template comments stops at pass 1 with a
`lab-assignment-comments` error, which is correct behavior and still proves the
tool is wired up. On a finished file you should see
`ece2300-format: formatted lab2/FullAdder_GL.v`.

**Step 5 — run the test suite.**

```
% cd <repo>/scripts/format
% python3 -m pytest -q
```

See [How to Test](#how-to-test) for the expected counts. Bazel is *not* needed
for any of these steps; it is only needed to build the fork in the first place.

## How to use this Tool in our Labs

To format a single file on ecelinux, run:

```
% ece2300-format <PATH-TO-FILE>
```

The tool accepts `.v`, `.sv`, and `.svh` files. If formatting succeeds, it prints
a confirmation message. If linting fails, it prints the lint error and stops
before the autoformat pass — but note that extra blank lines have already been
collapsed by then, since that precheck writes as it goes. See
[Pass 1: Prechecks and Linting](#pass-1-prechecks-and-linting).

**The file must be committed to git first.** Both passes overwrite the file in
place, so `ece2300-format` refuses to run on a file with uncommitted changes, on
an untracked or ignored file, or on a file outside a git repository. That way
`git checkout -- <file>` is always a way back if the formatter mangles
something. Commit your work first — do not stash it, since a stash leaves the
working copy dirty in a different way.

Run individual passes with `-1` and `-2`:

```
% ece2300-format -1 <PATH-TO-FILE>    # lint only
% ece2300-format -2 <PATH-TO-FILE>    # Verible format only
```

Each pass can also be run directly:

```
% format_lint.py <PATH-TO-FILE>
% format_general.py <PATH-TO-FILE>
```

You can also format through the build system:

```
% make format lab2/FullAdder_GL.v
```

## Pointing the Formatter at the Correct Verible

**This is the one thing you need to get right when Verible moves.**

Both passes shell out to binaries from the custom
[ece2300 Verible fork](https://github.com/cornell-ece2300/ece2300-verible). Stock
upstream Verible will *not* produce class style — the fork is what keeps `(` on
its own line, preserves the space in `.port (sig)`, and leaves `task ... endtask`
alone.

### How the binaries are found

Both binaries are looked up on `PATH` at runtime by `find_verible()` in
[format_utils.py](format_utils.py):

```python
VERIBLE_LINT_EXE   = "verible-verilog-lint"
VERIBLE_FORMAT_EXE = "verible-verilog-format"


def find_verible(exe_name, tool_name):
  exe = shutil.which(exe_name)
  if not exe:
    sys.exit(f"{tool_name}: Error: {exe_name} not found on PATH.")
  return exe
```

`find_verible_lint()` and `find_verible_format()` are one-line wrappers around it,
and are what `format_lint.py` and `format_general.py` call. This mirrors how
[ece2300-lint](../ece2300-lint) locates Verible, so both tools follow the same
install.

There is no path constant to edit — whichever `verible-verilog-lint` and
`verible-verilog-format` come first on `PATH` are the ones that run. To point the
formatter at a different build, change `PATH`:

```
% source setup-ece2300.sh                                       # class install
% export PATH=<path-to>/ece2300-verible-install/bin:$PATH       # local build
```

Do not hardcode paths in `format_lint.py` or `format_general.py` — they call the
finders.

**The hazard of resolving from `PATH`:** `shutil.which()` will happily pick up a
stock upstream Verible that happens to come first, and the result is non-class
formatting with no error at all. Nothing in the tool version-checks the binary,
so Step 2 of [Setup](#setup) is the only thing standing between you and silently
wrong output. Re-run it whenever `PATH` changes.

### When Verible is not on PATH

`find_verible()` exits the process (status 1) with a single message rather than
returning an error for the caller to handle, since no pass can do useful work
without the binary:

```
ece2300-format: Error: verible-verilog-format not found on PATH.
```

[ece2300-format](../ece2300-format) resolves both binaries up front, before
either pass runs, so a missing binary fails before the file is touched.
`format_lint.py` resolves the lint binary only *after* its ECE 2300 prechecks, so
those still report their own errors on a machine without Verible installed.

### Building the fork yourself

You need this only when there is no class install, or when you have changed the
fork and want the new behavior. Build in a clone of
[ece2300-verible](https://github.com/cornell-ece2300/ece2300-verible) and
install the binaries wherever you like — the install directory is arbitrary,
and whatever you choose is what you prepend to `PATH`:

```
% cd <path-to>/ece2300-verible
% bazel build :install-binaries
% ./.github/bin/simple-install.sh <install-dir>
% export PATH=<install-dir>:$PATH
```

Install *both* binaries from the same build. Mixing an upstream
`verible-verilog-format` with a fork `verible-verilog-lint` silently produces
non-class formatting, so confirm the pair afterwards:

```
% <install-dir>/verible-verilog-lint --version
% <install-dir>/verible-verilog-format --version
```

A fork build prints `Version head`; an upstream release prints a version string
such as `v0.0-4051-g9fdb4057`.

Bazel is needed only for this section. Running or testing the formatter against
an existing build does not need it.

### Verifying the lookup

```
% which verible-verilog-lint verible-verilog-format
```

Both must resolve, and to the fork rather than a stock upstream build. Note the
ecelinux binaries are Linux x86-64 ELF — they do not run on macOS, so local
testing must happen on ecelinux or in the devcontainer.

## How this Tool Works at a High Level

[ece2300-format](../ece2300-format) is the main orchestrator. With no flags it
runs both passes. [format_lint.py](format_lint.py) and
[format_general.py](format_general.py) implement each pass and can be run on
their own.

### Pass 1: Prechecks and Linting

[format_lint.py](format_lint.py) runs the ECE 2300-specific checks first, before
Verible sees the file:

- **Blank lines** — collapse runs of 2+ blank lines down to one. This is the only
  precheck that *fixes* the file; the rest reject it.
- **Lab-assignment banner comments** — reject leftover instructor template
  comments (`LAB ASSIGNMENT`, `remove these lines before starting your
  implementation`, long `''''''''''` quote banners). See coding-convention 6.6.
- **Class-style comments** — reject `// class`, `// module`, `// task`,
  `// function`, `// typedef`, `// interface` comment headers.

If any precheck fails, the pass returns immediately and Verible never runs.

Then `verible-verilog-lint` runs with the class ruleset in `VERIBLE_LINT_ARGS`
(`always-comb`, `always-ff-non-blocking`, `case-missing-default`, `module-port`,
`no-tabs`, `signal-name-style`, and a custom `parameter-name-style` where
parameters are snake_case and localparams are snake_case or ALL_CAPS). Verible's
raw diagnostics are rewritten into short student-facing messages via
`ECE2300_LINT_MESSAGES`.

`instance-shadowing` is deliberately off. Verible treats the port name in a
named connection as a declaration, so the class style `.clk (clk)` is reported
as `clk` shadowing the `clk` port. That fires on nearly every lab file with an
instantiation, in both the fork and upstream Verible.

### Pass 2: Verible Formatting

If linting passes, [format_general.py](format_general.py) runs
`verible-verilog-format` with the class options in `VERIBLE_FORMAT_ARGS`:
74-column limit, 2-space indentation, aligned assignments, ports, and named
ports, and right-aligned packed dimensions.

Formatting is done with Verible's `--inplace` flag. Verible formats into memory
first and only writes on success, so a file that fails to parse is left
untouched. It also skips the write entirely when the formatted output matches the
input, which keeps timestamps stable for `make`.

`--failsafe_success=false` is also passed. Verible defaults that flag to *true*,
which exits 0 even on a parse error; turning it off is what makes the return code
usable as a CI gate.

## Directory Layout

```
scripts/
├── ece2300-format          # main orchestrator (alongside ece2300-lint)
└── format/
    ├── format_general.py   # pass 2: Verible autoformat
    ├── format_lint.py      # pass 1: prechecks + Verible lint
    ├── format_utils.py     # shared helpers + Verible PATH lookup
    ├── README.md
    └── tests/
        ├── __init__.py
        ├── conftest.py
        ├── helpers.py
        ├── regen_golden.py
        ├── test_general_format.py
        ├── test_lint.py
        ├── test_rem_whitespace.py
        └── test_files/
            ├── blank_lines/
            ├── general_format/
            │   └── expected/    # golden formatter output
            └── lint/
                └── valid/       # lab code that must lint clean
```

Verible binaries are resolved from `PATH` by `find_verible()` in
[format_utils.py](format_utils.py) — see
[Pointing the Formatter at the Correct Verible](#pointing-the-formatter-at-the-correct-verible).

## How to Test

From the `format` directory, run:

```
% source setup-ece2300.sh   # on ecelinux
% pytest
```

Tests that shell out to Verible are gated behind the `requires_verible` marker in
`tests/conftest.py`, which skips them when `shutil.which()` cannot find either
binary on `PATH`, so the suite still runs (with skips) on a machine without
Verible.

| Test module | Pass under test | Needs Verible |
|---|---|---|
| `test_lint.py` | Prechecks plus Verible lint rules | Partly |
| `test_general_format.py` | Verible autoformat | Yes |
| `test_rem_whitespace.py` | Blank line collapsing (`collapse_extra_blank_lines`) | No |

`tests/helpers.py` contains shared utilities for the lint and general-format
runners. `tests/conftest.py` provides the pytest fixtures, including
`requires_verible`.

On ecelinux with the fork binaries in place:

```
64 passed
```

Everywhere else the pure-Python subset still runs and the Verible-gated tests
skip:

```
27 passed, 37 skipped
```

Each fixture group is guarded against becoming a no-op:
`test_fixtures_are_not_already_class_formatted` fails if a formatting fixture
already matches the formatter's output, and `test_blank_line_fixture_files`
fails if a fixture no longer contains a run of blank lines to collapse. Without
those guards a pre-formatted fixture would satisfy the convergence and
idempotency assertions for free.

Note that neither the fork nor upstream Verible breaks a long continuous
assignment such as
`assign count_load = ( state == 2'b00 ) || ( state == 2'b10 ) || ( rst && count_done );`,
so the column limit is not enforced for those lines. Do not write a fixture
that depends on them being wrapped.

### Test Fixtures

Every fixture under `tests/test_files/` is real lab code rather than invented
SystemVerilog, so the suite exercises the same constructs students hand in:
`(* keep=1 *)` port attributes, include guards, gate-level primitives,
`always_ff` reset chains, and `casez` state tables.

- `tests/test_files/lint/` — one file per rule, each a lab module edited to
  break that rule and nothing else. The header comment in each file names the
  lab file it came from and the edit that was made, for example
  `Mux8_1b_AlwaysStar_RTL.v` is `lab3/Mux8_1b_RTL.v` with `always_comb` rewritten
  as `always @(*)`.
- `tests/test_files/lint/valid/` — finished lab implementations with the
  instructor template comments stripped, as a student would submit them. These
  must lint clean; `test_lint_valid_files_pass` globs the directory, so a new
  file is picked up automatically.
- `tests/test_files/general_format/` — inputs written in the exact shape the
  fork has to correct. `mux4_32b_paren_inline.v` declares
  `module Mux4_32b_RTL (`, which must come out as `module Mux4_32b_RTL` with `(`
  on the next line; `mux4_32b_sprawl.v` is the same module mangled the opposite
  way, with `(` already below but ragged indentation and each case item split
  across two lines, so the two must converge on identical output;
  `noteplayerctrl_inst_inline.v` writes both instantiations as
  `DFFR_RTL s0_dff ( .clk(clk), ... );`, which must come out as
  `DFFR_RTL s0_dff` with `(` on its own line and a space in `.clk (clk)`. Each
  of those tests asserts the *input* shape first, so the fixture cannot be
  quietly pre-corrected.
- `tests/test_files/general_format/expected/` — the golden output, compared
  byte for byte by `test_formatted_output_matches_golden`. This is what catches
  an unintended change in the fork's style. Goldens are named after the module,
  not the fixture, because fixtures that are one module mangled several ways
  share a single golden: `mux4_32b_paren_inline.v` and `mux4_32b_sprawl.v` both
  pin to `Mux4_32b_RTL.v`, which is what asserts they converge. The mapping is
  `GOLDEN_BY_FIXTURE` in `tests/helpers.py`, read by both the test and
  `regen_golden.py`; a fixture with no entry there is a hard error rather than
  a silent skip. After an *intended* change, regenerate and review the diff:

```
% python3 tests/regen_golden.py
```
- `tests/test_files/blank_lines/` — lab modules padded with runs of blank lines,
  two deep, three deep, and eight deep. Each fixture's padding depth is pinned
  in the test parameters, and every fixture also keeps a single blank line
  somewhere to show those survive.

Two constraints when adding a fixture. Verible's `module-filename` rule means
the file name must match the module name, and the ECE 2300 prechecks run before
Verible, so a fixture aimed at a Verible rule must not also carry a leftover
`LAB ASSIGNMENT` banner or a `// module`-style comment — the precheck would fire
first and the file would never reach Verible.

### Note on the retired class-format test modules

The tool once had a Python-based class-format pipeline that rewrote module
declarations, instantiations, named ports, `if`/`else` bodies, and comment
spacing directly. That pipeline was replaced by a direct call to the patched
Verible, which now does that work through
[the fork](https://github.com/cornell-ece2300/ece2300-verible) instead.

The test modules covering it (`test_comment_spacing.py`, `test_if_else.py`,
`test_module_decl.py`, `test_module_instances.py`, `test_named_ports.py`) and
their fixture directories have been removed along with the helpers they called.
Those behaviors are now the fork's responsibility — add coverage for them in
`ece2300-verible`, not here. Do not reintroduce Python-side reimplementations of
formatting that Verible already performs.

# How to Expand Functionality

## Adding or Changing Verible Lint Rules

Edit `VERIBLE_LINT_ARGS` and `ECE2300_LINT_MESSAGES` in
[format_lint.py](format_lint.py). Add the rule to the `--rules=` list and, if you
want a custom student-facing message, add an entry to `ECE2300_LINT_MESSAGES`.

## Adding or Changing Verible Format Options

Edit `VERIBLE_FORMAT_ARGS` in [format_general.py](format_general.py). See the
[Verible formatter documentation](https://chipsalliance.github.io/verible/verilog_format.html)
for available flags. Keep `--inplace` and `--failsafe_success=false` in the list;
`run()` depends on both.

Watch for duplicate flags — Verible takes the last occurrence, so a repeated flag
silently overrides the earlier one.

## Adding a New Precheck

Add the check function to [format_lint.py](format_lint.py), returning a list of
`"{path}:{line}:{col}: {message} [{rule-name}]"` strings, call it from `run()`
before the Verible subprocess, and add a matching entry to
`ECE2300_LINT_MESSAGES`.
