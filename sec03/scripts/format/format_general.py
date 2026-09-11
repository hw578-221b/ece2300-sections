#!/usr/bin/env python3
#=========================================================================
# ece2300-format-general <file>
#=========================================================================
#
# Pass 2: Autoformat with Verible.
# Overwrites the file in place.
#
# Author : Anthony Song
# Last Maintained : Jun 30, 2026
#

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from format_utils import (
  collapse_extra_blank_lines,
  find_verible_format,
  validate_file,
)

TOOL_NAME = "ece2300-format-general"

VERIBLE_FORMAT_ARGS = [
  # Overwrite the file directly. Verible formats into memory first and only
  # writes on success, so a file that fails to parse is left untouched.
  "--inplace",
  # Verible defaults this to true, which exits 0 even on a parse error.
  # Turn it off so our return code actually reports failures.
  "--failsafe_success=false",
  "--column_limit=74",
  "--indentation_spaces=2",
  "--assignment_statement_alignment=align",
  "--port_declarations_alignment=align",
  "--port_declarations_indentation=indent",
  "--wrap_spaces=2",
  "--named_port_alignment=align",
  "--named_port_indentation=indent",
  "--port_declarations_right_align_packed_dimensions=true",
  "--module_net_variable_alignment=align",
]


def run(path):
  verible_format = find_verible_format(TOOL_NAME)

  text = path.read_text(encoding="utf-8")
  fixed_text = collapse_extra_blank_lines(text)
  if fixed_text != text:
    path.write_text(fixed_text, encoding="utf-8")

  result = subprocess.run(
    [verible_format, *VERIBLE_FORMAT_ARGS, str(path)],
  )
  if result.returncode != 0:
    print(f"{TOOL_NAME}: Failed formatting {path}", file=sys.stderr)
    return 1
  return 0


def main(argv=None):
  ap = argparse.ArgumentParser(
    description="Autoformat one Verilog/SystemVerilog file with Verible.",
  )
  ap.add_argument(
    "file",
    help="Verilog/SystemVerilog file to format (.v, .sv, or .svh)",
  )
  args = ap.parse_args(argv)

  path = validate_file(args.file, TOOL_NAME)
  if path is None:
    return 1

  return run(path)


if __name__ == "__main__":
  sys.exit(main())
