  # ECE2300 Verible Linting
  - Author: Kaan Akan
  - Date:   08/18/2026

  ## Why This Exists

  The Verilator linter is used for mainly structural and correctness issues but does not enforce our custom coding conventions. To enforce these coding conventions, Verible was chosen due to its flexibility in adding lint rule files with modularity. The ECE2300 labs need to distinguish between gate level, structural, and RTL files to apply correct class rulesets. This is achieved by the following:

  [`ece2300-lint`](../ece2300-lint) collects .v hardware files including the given top level or test file and its included files, and runs the Verible fork on each file in [`rulesets.yaml`](rulesets.yaml), by calling `verible-verilog-lint` on each matching file. The  custom rules and their tests live in the [`ece2300-verible`](https://github.com/cornell-ece2300/ece2300-verible) fork.

  ## Running the Linter

  From the top of the labs repository, a normal call looks like this:

  ```bash
  scripts/ece2300-lint \
    --rulesets scripts/lint/rulesets.yaml \
    -I . \
    lab1/test/BinaryToSevenSegUnopt_GL-test.v
  ```

  The `--rulesets` argument gives the path to the rule configuration. The `-I` argument gives a directory to search for `` `include`` files and the repository root.

  For normal course use, `setup-ece2300.sh` loads the course Verible module and adds the globally installed binary to `PATH`. To test a local Verible build, unload that module and add the local build's binary directory to `PATH`.

  ## Makefile Call

  The linter is called from the [`Makefile.in`](../../Makefile.in). The Makefile defines both the script and ruleset paths:

  ```make
  ECE2300_LINT          := $(scripts_dir)/ece2300-lint
  ECE2300_LINT_RULESETS := $(scripts_dir)/lint/rulesets.yaml
  ```

  It then runs the linter after Verilator and before Icarus Verilog:

  ```make
  $(ECE2300_LINT) --rulesets $(ECE2300_LINT_RULESETS) -I $(top_dir) $<
  ```

  ## File Collection

  [`collect_files.py`](collect_files.py) starts with the test file and follows every `` `include`` it can resolve through the `-I` directory. It continues recursively so included files can include more files. Dependencies are placed before the file that included them, which means lower-level hardware is linted first, which helps prevent errors/issues in lower hierarchy files reaching files that include them.

  File collection collects every included file in a to-be linted file path list but does not decide what should be linted. This decision is made later by matching the collected file to the rulesets.yaml file and calling the rules appropriate to its ruleset.

  ## Matching Rulesets

  `rulesets.yaml` contains named rule groups and maps relative file names to those groups:

  ```yaml
  rulesets:
    GL:
      - forbid-special-blocks
      - restrict-assign-rhs
      - restrict-gate-primitives
      - ...

    modules:
    lab1/BinaryToSevenSegOpt_GL.v:   GL
    lab1/BinaryToSevenSegUnopt_GL.v: GL
  ```

  The linter converts each collected file into a path relative to the repository root given by `-I`. It uses paths like the following: `lab1/BinaryToSevenSegOpt_GL.v` to lookup the matching ruleset under `files`. Files that are not listed are skipped.

  ```bash
  verible-verilog-lint --ruleset=none --rules=<matching-rules> <file>
  ```

  The script stops when the first file fails, this prevents us from giving students a long chain of error messages and matches how the Verilator does its linting.

  ## Adding a Verible Rule

  New rules belong in and should be added to the `ece2300-verible` fork under `verible/verilog/analysis/checkers`. Add the rule's header, implementation, and test files, register it `VERILOG_REGISTER_LINT_RULE`, and add its library and test targets to the checkers `BUILD` file. Run the new Bazel test in the Verible repository, then add the rule name to the appropriate group in this repository's `rulesets.yaml`. When the local build looks good, the course administrator/professor can globally install the modified fork with the following:

  source setup-ece2300.sh

  git clone https://github.com/cornell-ece2300/ece2300-verible
  cd ece2300-verible

  bazel --output_base=/tmp/${USER}-verible build -c opt \
    :install-binaries

  .github/bin/simple-install.sh \
    ${ECE2300_INSTALL}/pkgs/verible-0.0-ece2300-commit_id/bin
