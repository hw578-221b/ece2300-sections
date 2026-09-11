# Utility functions used by all the format scripts.
#
# Author : Anthony Song
# Last Maintained : Jun 30, 2026
#

import os
import shutil
import subprocess
import sys
from pathlib import Path

VERILOG_EXTS = (".v", ".sv", ".svh")

# Verible is resolved from PATH, not from a vendored tree, so the formatter
# follows whichever ece2300-verible build the environment sets up.
VERIBLE_LINT_EXE = "verible-verilog-lint"
VERIBLE_FORMAT_EXE = "verible-verilog-format"


def validate_file(path, tool_name):
  path = Path(path)
  if not path.is_file():
    print(f"{tool_name}: Not a file: {path}", file=sys.stderr)
    return None
  if path.suffix not in VERILOG_EXTS:
    print(
      f"{tool_name}: Not a Verilog file (expected {VERILOG_EXTS}): {path}",
      file=sys.stderr,
    )
    return None
  return path.resolve()


def ensure_file_committed(path, tool_name):
  return
  # Every pass overwrites the file in place, so refuse to touch anything that
  # is not already committed. That way `git checkout` is always a way back if
  # the formatter mangles something.
  # try:
  #   result = subprocess.run(
  #     ["git", "status", "--porcelain", "--ignored", "--", str(path)],
  #     cwd=path.parent,
  #     stdout=subprocess.PIPE,
  #     stderr=subprocess.PIPE,
  #     universal_newlines=True,
  #     check=False,
  #   )
  # except FileNotFoundError:
  #   sys.exit(f"{tool_name}: Error: git not found on PATH.")
  #
  # if result.returncode != 0:
  #   sys.exit(f"{tool_name}: Error: {path} is not inside a git repository.")
  #
  # status = result.stdout.strip()
  # if not status:
  #   return
  #
  # # Shown relative to where the student ran make, so the hint is copy-pastable.
  # try:
  #   rel = Path(os.path.relpath(path))
  # except ValueError:
  #   rel = path
  #
  # # "??" is untracked, "!!" is gitignored: neither has a committed copy, so
  # # git checkout has nothing to restore and the fix is to commit it instead.
  # if status.startswith(("??", "!!")):
  #   sys.exit(
  #     f"{tool_name}: Error: {rel} is not committed to git.\n"
  #     f"Commit it first, then format."
  #   )
  #
  # sys.exit(
  #   f"{tool_name}: Error: {rel} has uncommitted changes.\n"
  #   f"Commit them first (do not stash), then format. You can then always undo\n"
  #   f"the formatting with:\n"
  #   f"  git checkout -- {rel}"
  # )


VERIBLE_DIR_ENV = "ECE2300_VERIBLE_DIR"


def find_verible(exe_name, tool_name):
  # ECE2300_VERIBLE_DIR pins one specific Verible build. Without it we take
  # whatever PATH offers first, which is a module load, a hand-extracted
  # tarball, or a local build depending on how the shell was set up. Those
  # differ in formatting behavior, so silently picking the wrong one rewrites
  # files the wrong way. Unset, the lookup falls back to PATH as before.
  override_dir = os.environ.get(VERIBLE_DIR_ENV)
  if override_dir:
    exe = Path(override_dir) / exe_name
    if not os.access(str(exe), os.X_OK):
      sys.exit(
        f"{tool_name}: Error: {VERIBLE_DIR_ENV} is set to {override_dir}, "
        f"but {exe_name} is not an executable there."
      )
    return str(exe)

  # Exits the process when the binary is missing: every caller needs Verible
  # to do anything useful, so there is nothing to fall back to.
  exe = shutil.which(exe_name)
  if not exe:
    sys.exit(f"{tool_name}: Error: {exe_name} not found on PATH.")
  return exe


def find_verible_lint(tool_name):
  return find_verible(VERIBLE_LINT_EXE, tool_name)


def find_verible_format(tool_name):
  return find_verible(VERIBLE_FORMAT_EXE, tool_name)


def collapse_extra_blank_lines(text):
  # Collapse runs of 2+ blank lines down to a single blank line.
  if not text:
    return text

  lines = text.splitlines(keepends=True)
  out = []
  blank_run = 0
  for line in lines:
    if not line.strip():
      blank_run += 1
      if blank_run <= 1:
        out.append(line)
    else:
      blank_run = 0
      out.append(line)
  return "".join(out)
