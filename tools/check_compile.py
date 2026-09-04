#!/usr/bin/env python3
"""Syntax-check every Fortran example in the book with strict compiler flags.

The project's CMakeLists only builds part of the tree (the ``make_examples`` and
``cmake_examples`` directories, for instance, are built by their own chapters'
build files).  This script covers *all* of ``source/**/*.f90`` so no example can
drift out of compiling.

Each directory is compiled as its own scope, in module-dependency order, with
``mf_lib`` always available because several examples ``use`` its modules.

Usage::

    python tools/check_compile.py [ROOT] [--fc gfortran] [--std f2018]

Exits non-zero if any file fails to compile.
"""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from collections import defaultdict
from pathlib import Path

MODULE_DEF = re.compile(r'^\s*module\s+(?!procedure\b)(\w+)\s*$', re.I)
SUBMODULE_DEF = re.compile(r'^\s*submodule\s*\(\s*(\w+)[^)]*\)\s*(\w+)', re.I)
USE_STMT = re.compile(r'^\s*use\s*(?:,\s*(?:non_)?intrinsic\s*::)?\s*(\w+)', re.I)

# Provided by the compiler, never by a file in this tree.
INTRINSIC_MODULES = {
    'iso_c_binding', 'iso_fortran_env', 'ieee_arithmetic', 'ieee_exceptions',
    'ieee_features', 'omp_lib', 'omp_lib_kinds', 'mpi', 'mpi_f08',
}

# `loc()` is a GNU/Intel extension used by the array-slice example to show
# where a slice actually lives in memory.  -fall-intrinsics keeps it available
# while the rest of the standard checking stays on.
#
# Coarrays are disabled in gfortran unless -fcoarray is given; a single image
# is all the coarray example needs in order to be checked.
EXTRA_FLAGS = ['-fall-intrinsics', '-fcoarray=single']


def scan(path: Path) -> tuple[set[str], set[str]]:
    """Return (modules defined, modules used) for one source file."""
    defines: set[str] = set()
    uses: set[str] = set()
    for line in path.read_text(encoding='utf-8').splitlines():
        m = MODULE_DEF.match(line)
        if m:
            defines.add(m.group(1).lower())
            continue
        m = SUBMODULE_DEF.match(line)
        if m:
            uses.add(m.group(1).lower())
            continue
        m = USE_STMT.match(line)
        if m:
            uses.add(m.group(1).lower())
    return defines, uses


def order(files: list[Path]) -> list[Path]:
    """Topologically sort files so a module is compiled before its users."""
    info = {f: scan(f) for f in files}
    provider: dict[str, Path] = {}
    for f in files:                       # first definition wins; scope is one dir
        for mod in info[f][0]:
            provider.setdefault(mod, f)

    ordered: list[Path] = []
    state: dict[Path, int] = defaultdict(int)   # 0 unvisited, 1 in progress, 2 done

    def visit(f: Path) -> None:
        if state[f] == 2 or state[f] == 1:      # done, or a cycle we simply break
            return
        state[f] = 1
        for mod in sorted(info[f][1]):
            if mod in INTRINSIC_MODULES:
                continue
            dep = provider.get(mod)
            if dep is not None and dep != f:
                visit(dep)
        state[f] = 2
        ordered.append(f)

    for f in sorted(files):
        visit(f)
    return ordered


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('root', nargs='?', default='source', type=Path)
    ap.add_argument('--fc', default='gfortran')
    ap.add_argument('--std', default='f2018')
    args = ap.parse_args(argv[1:])

    if shutil.which(args.fc) is None:
        print(f'error: compiler {args.fc!r} not found', file=sys.stderr)
        return 2
    if not args.root.is_dir():
        print(f'error: {args.root} is not a directory', file=sys.stderr)
        return 2

    shared = sorted((args.root / 'mf_lib').glob('*.f90'))

    groups: dict[Path, list[Path]] = defaultdict(list)
    for f in sorted(args.root.rglob('*.f90')):
        groups[f.parent].append(f)

    flags = [f'-std={args.std}', *EXTRA_FLAGS,
             '-Wall', '-pedantic', '-fimplicit-none', '-fsyntax-only']

    checked = 0
    failures: list[tuple[Path, str]] = []

    for directory in sorted(groups):
        files = groups[directory]
        scope = files if directory.name == 'mf_lib' else shared + files
        with tempfile.TemporaryDirectory() as moddir:
            for f in order(scope):
                if f not in files:
                    # A shared dependency: compile it so its .mod exists, but
                    # report it under its own directory, not here.
                    subprocess.run([args.fc, *flags, f'-J{moddir}', str(f)],
                                   capture_output=True, text=True)
                    continue
                proc = subprocess.run(
                    [args.fc, *flags, f'-J{moddir}', str(f)],
                    capture_output=True, text=True)
                checked += 1
                if proc.returncode != 0:
                    failures.append((f, proc.stderr.strip()))
                elif proc.stderr.strip():
                    print(f'--- {f} (warnings)')
                    print(proc.stderr.rstrip())

    for f, err in failures:
        print(f'=== FAILED {f}')
        print(err)

    print(f'\nchecked {checked} files with '
          f'{args.fc} {" ".join(flags)}: {len(failures)} failure(s)')
    return 1 if failures else 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
