*******************************
Visual Studio Code for Fortran
*******************************

Visual Studio Code is a free, cross-platform editor that most students already
have installed for something else. With one extension and one language server it
becomes a capable Fortran environment: completion that knows the modules in the
project, errors underlined as they are typed, jump to definition, and a
debugger.

This chapter covers the setup. It assumes a working compiler; if there is none
yet, :doc:`chapter_getting_started` covers installing one.

The Modern Fortran extension
============================

The extension to install is **Modern Fortran**, published by fortran-lang, whose
identifier in the marketplace is ``fortran-lang.linter-gfortran``. Open the
Extensions view with :kbd:`Ctrl+Shift+X`, search for *Modern Fortran* and
install it, or from a terminal::

   $ code --install-extension fortran-lang.linter-gfortran

On its own the extension provides syntax highlighting, snippets and diagnostics
from the compiler. The features that make the difference on a real project —
completion, hover, go to definition — come from the language server, which is a
separate program.

The language server
===================

**fortls** is the Fortran language server. It parses the whole project rather
than the open file, which is what allows it to know that a name in one file is
declared in a module in another. It is a Python program, installed with pip::

   $ pip install fortls

or with conda::

   $ conda install -c conda-forge fortls

The extension finds it on the path and starts it automatically. If it is
installed somewhere the path does not cover, name it in the settings:

.. code-block:: json

   {
       "fortran.fortls.path": "/home/jane/.local/bin/fortls"
   }

With the server running the editor gains:

- completion of names from every module in the project, not just the open file,
- hover showing a procedure's interface and its argument declarations,
- **Go to Definition** and **Peek Definition** across files,
- a symbol outline of the file, and workspace-wide symbol search,
- rename that updates every use of a name.

Telling the tools where the code is
===================================

Two settings matter more in Fortran than in most languages, and both are about
finding things.

The first is a project file for the language server. fortls reads a ``.fortls``
file in the root of the project, in JSON, which lists where the sources are:

.. code-block:: json

   {
       "source_dirs": ["src", "app", "test"],
       "include_dirs": ["include"]
   }

Without it fortls searches the whole workspace, which is usually right for a
small project and usually wrong for one with a ``build`` directory full of
generated copies.

The second is the include path for the linter. The extension checks a file by
compiling it, and a file that uses a module cannot be compiled unless the
``.mod`` file for that module can be found. If the editor underlines a
**use**-statement that is perfectly correct, this is why. Point it at wherever
the build puts its module files:

.. code-block:: json

   {
       "fortran.linter.compiler": "gfortran",
       "fortran.linter.includePaths": [
           "${workspaceFolder}/build/**"
       ],
       "fortran.linter.extraArgs": ["-std=f2018", "-Wall", "-fimplicit-none"]
   }

``fortran.linter.extraArgs`` is worth setting to the same options the project is
built with. The warnings then appear in the editor as the code is written rather
than at the end of a build.

Settings can go in the user profile or, better for anything path-related, in
``.vscode/settings.json`` inside the project, where they are shared with anyone
else who opens it.

Formatting
==========

The extension can reformat a file with either **findent** or **fprettify**,
neither of which it installs::

   $ pip install fprettify

.. code-block:: json

   {
       "fortran.formatting.formatter": "fprettify",
       "fortran.formatting.fprettifyArgs": ["--indent", "4"],
       "editor.formatOnSave": true
   }

Both are opinionated about indentation and about where continuation lines go. It
is worth agreeing on one and its arguments at the start of a project rather than
part way through, since the first run reformats every line it disagrees with and
makes the change unreadable in a diff.

Building from the editor
========================

VS Code runs builds as *tasks*, defined in ``.vscode/tasks.json``. A task for an
fpm project:

.. code-block:: json

   {
       "version": "2.0.0",
       "tasks": [
           {
               "label": "fpm build",
               "type": "shell",
               "command": "fpm",
               "args": ["build", "--flag", "-Wall -std=f2018 -fcheck=all -g"],
               "group": { "kind": "build", "isDefault": true },
               "problemMatcher": "$gcc"
           },
           {
               "label": "fpm test",
               "type": "shell",
               "command": "fpm",
               "args": ["test"],
               "group": "test"
           }
       ]
   }

:kbd:`Ctrl+Shift+B` then runs the default build task. ``"problemMatcher":
"$gcc"`` is what turns gfortran's messages into entries in the Problems panel
that can be clicked, and it works for gfortran despite the name.

For a project built with CMake, the **CMake Tools** extension
(``ms-vscode.cmake-tools``) is a better fit than a hand-written task. It reads
the ``CMakeLists.txt``, offers a kit and build-type picker in the status bar,
and configures and builds without a task file. The CMake chapter,
:doc:`chapter_fortran_projects`, covers the build files themselves.

Debugging
=========

VS Code has no Fortran debugger of its own. It drives **gdb**, through the
**C/C++** extension (``ms-vscode.cpptools``), which works on Fortran binaries
because gdb does.

The program has to be compiled with debugging information, which means the
``-g`` option described in :doc:`app_compiling_fortran`, and preferably without
optimisation. A launch configuration in ``.vscode/launch.json``:

.. code-block:: json

   {
       "version": "0.2.0",
       "configurations": [
           {
               "name": "Debug myprog",
               "type": "cppdbg",
               "request": "launch",
               "program": "${workspaceFolder}/build/myprog",
               "args": [],
               "cwd": "${workspaceFolder}",
               "MIMode": "gdb"
           }
       ]
   }

Breakpoints are set by clicking in the margin, and :kbd:`F5` starts the program.
Array variables appear in the Variables panel with their elements, and an
expression such as ``a(3,4)`` can be added to the Watch panel.

On Windows, ``MIMode`` should still be ``gdb`` and the debugger is the one that
came with MSYS2; add ``"miDebuggerPath"`` pointing at it if it is not on the
path. With the Intel compilers, ``ifx`` produces binaries that gdb can read, but
Intel's own ``gdb-oneapi`` understands more of the Fortran runtime.

A note on what to expect
========================

The tooling around Fortran is thinner than around C++ or Python, and it shows.
Completion inside deeply nested derived types is patchy, refactoring beyond
rename does not exist, and the linter occasionally underlines code that compiles
perfectly well. None of that makes the setup less worth doing — going from a
plain text editor to one that knows what a name refers to is the single largest
improvement available — but it is worth knowing in advance which limitations are
the tools and which are mistakes in the code.
