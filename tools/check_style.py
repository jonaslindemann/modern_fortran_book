#!/usr/bin/env python3
"""Style gate for the book's Fortran examples.

The book tells readers that tab characters are not part of the Fortran standard
and that every code unit should disable the implicit type rule.  This script
holds the examples to that same standard, so the code readers copy matches the
advice they are given.

Checks, per ``source/**/*.f90``:

* the file decodes as UTF-8
* no tab characters
* no trailing whitespace
* the file ends with exactly one newline
* every top-level program unit contains an ``implicit none``

Contained procedures (those after a ``contains``) and module procedures inherit
IMPLICIT NONE from their host, so they are deliberately not required to repeat
it.

Usage::

    python tools/check_style.py [ROOT]      # default ROOT is "source"

Exits non-zero if any check fails.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

# --- program-unit grammar -------------------------------------------------

PREFIX = r'(?:(?:pure|impure|elemental|recursive|module)\s+)*'
TYPESPEC = (r'(?:(?:real|integer|complex|logical|character|double\s+precision'
            r'|type)\s*(?:\([^)]*\)|\*\s*\d+)?\s*)?')

OPENERS = [
    ('program',    re.compile(r'^\s*program\s+\w+', re.I)),
    ('submodule',  re.compile(r'^\s*submodule\s*\(', re.I)),
    ('module',     re.compile(r'^\s*module\s+(?!procedure\b)\w+\s*$', re.I)),
    ('subroutine', re.compile(r'^\s*' + PREFIX + r'subroutine\s+\w+', re.I)),
    ('function',   re.compile(r'^\s*' + PREFIX + TYPESPEC + PREFIX
                              + r'function\s+\w+', re.I)),
    ('interface',  re.compile(r'^\s*(abstract\s+)?interface\b', re.I)),
    ('type',       re.compile(r'^\s*type\s*(?:,[^:]*)?(?:::)?\s*\w+\s*$', re.I)),
    ('block',      re.compile(r'^\s*(\w+\s*:\s*)?block\s*$', re.I)),
]
UNITS = ('program', 'submodule', 'module', 'subroutine', 'function')

# Only closes the constructs opened above.  `end do` / `end if` / `end select`
# / `end where` / `end associate` must NOT match, or they unbalance the depth
# counter and make contained procedures look like top-level units.
CLOSE = re.compile(
    r'^\s*end\s*$|'
    r'^\s*end\s*(program|module|submodule|subroutine|function|interface|type'
    r'|block)\b',
    re.I)

IMPLICIT_NONE = re.compile(r'^\s*implicit\s+none', re.I)
CONTAINS = re.compile(r'^\s*contains\s*$', re.I)
BLANK_OR_COMMENT = re.compile(r'^\s*(!.*)?$')


def opener(line: str) -> str | None:
    for kind, rx in OPENERS:
        if rx.match(line):
            return kind
    return None


def units_missing_implicit_none(lines: list[str]) -> list[tuple[int, str]]:
    """Return (line number, kind) for each top-level unit lacking implicit none."""
    missing: list[tuple[int, str]] = []
    depth = 0
    unit: dict | None = None

    for i, line in enumerate(lines, 1):
        if BLANK_OR_COMMENT.match(line):
            continue
        if CLOSE.match(line) and not opener(line):
            depth = max(0, depth - 1)
            if unit and depth == 0:
                if not unit['has']:
                    missing.append((unit['line'], unit['kind']))
                unit = None
            continue
        kind = opener(line)
        if kind:
            if depth == 0 and kind in UNITS:
                unit = {'kind': kind, 'line': i, 'has': False, 'done': False}
            depth += 1
            continue
        if unit and depth == 1 and not unit['done']:
            if CONTAINS.match(line):
                unit['done'] = True
            elif IMPLICIT_NONE.match(line):
                unit['has'] = True

    if unit and not unit['has']:          # unterminated unit at end of file
        missing.append((unit['line'], unit['kind']))
    return missing


def check(path: Path) -> list[str]:
    problems: list[str] = []
    raw = path.read_bytes()

    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError as exc:
        return [f'{path}: not valid UTF-8 ({exc})']

    if not raw.endswith(b'\n'):
        problems.append(f'{path}: no newline at end of file')

    lines = text.replace('\r\n', '\n').split('\n')
    if len(lines) >= 2 and lines[-1] == '' and lines[-2] == '':
        problems.append(f'{path}: blank line(s) at end of file')

    for n, line in enumerate(lines, 1):
        if '\t' in line:
            problems.append(f'{path}:{n}: tab character '
                            f'(not part of the Fortran standard)')
        if line != line.rstrip():
            problems.append(f'{path}:{n}: trailing whitespace')

    for n, kind in units_missing_implicit_none(lines):
        problems.append(f'{path}:{n}: {kind} has no "implicit none"')

    return problems


def main(argv: list[str]) -> int:
    root = Path(argv[1] if len(argv) > 1 else 'source')
    if not root.is_dir():
        print(f'error: {root} is not a directory', file=sys.stderr)
        return 2

    files = sorted(root.rglob('*.f90'))
    problems = [p for f in files for p in check(f)]

    for p in problems:
        print(p)

    print(f'\nchecked {len(files)} files, {len(problems)} problem(s)')
    return 1 if problems else 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
