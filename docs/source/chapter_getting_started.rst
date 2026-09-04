***************
Getting started
***************

Before reading about the language itself it is useful to be able to run
something. This chapter contains the shortest path from an empty directory to a
program that prints on the screen: install a compiler, compile a source file and
run the result. It then shows how the same work is done with **fpm**, the
Fortran Package Manager, which is the simplest way of handling a project that
consists of more than a single file.

Nothing in this chapter is needed to understand the rest of the book, but with a
working compiler the examples in the following chapters, and the exercises in
:doc:`app_exercises`, can be tried out as they are read.

Installing a Fortran compiler
=============================

A Fortran compiler translates source code into an executable program. The
examples in this book are compiled with **gfortran**, the Fortran compiler in
the GNU Compiler Collection. It is free, available on all common platforms and
implements the standards described in this book.

.. tab-set::

   .. tab-item:: Linux

      On Debian and Ubuntu::

         $ sudo apt install gfortran

      On Fedora and Red Hat::

         $ sudo dnf install gcc-gfortran

   .. tab-item:: macOS

      gfortran is distributed as part of GCC, which is most easily installed
      with `Homebrew <https://brew.sh>`_::

         $ brew install gcc

   .. tab-item:: Windows

      There are several alternatives. `MSYS2 <https://www.msys2.org>`_ provides
      a package manager and an up to date GCC. After installing MSYS2, open the
      UCRT64 shell and run::

         $ pacman -S mingw-w64-ucrt-x86_64-gcc-fortran

      The Windows Subsystem for Linux, WSL, is another option and gives access
      to the same tools as a Linux installation.

   .. tab-item:: conda

      If Python is already installed through conda or Miniforge, a compiler can
      be installed into the same environment on all platforms::

         $ conda install -c conda-forge fortran-compiler

Intel also distributes its Fortran compiler, **ifx**, free of charge as part of
the oneAPI HPC Toolkit. It is a good complement to gfortran when a program is to
be tested with more than one compiler.

To check that the installation works, ask the compiler for its version::

   $ gfortran --version
   GNU Fortran (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0

Your first program
==================

Create a file named ``hello.f90`` with the following contents:

.. literalinclude:: ../../source/getting_started/hello.f90
   :language: Fortran
   :linenos:

The **program**-statement opens the main program and **end program** closes it.
**implicit none** disables the implicit type rule, which is described in the
next chapter and should be present in every code unit that is written today.
The **write**-statement writes to the screen.

The file name extension ``.f90`` tells the compiler that the file is written in
free source form. It does not mean that the code has to follow the Fortran 90
standard - the same extension is used for Fortran 2003, 2008 and 2018 code.

Compile the file by giving it to the compiler, and use the ``-o``-option to
choose the name of the executable::

   $ gfortran hello.f90 -o hello

The program is then run from the same directory::

   $ ./hello
    Hello, world!

On Windows the compiler produces ``hello.exe``, which is run with ``.\hello`` in
PowerShell or just ``hello`` in a command prompt.

Compiler options worth using from the start
===========================================

By default the compiler reports only what prevents it from producing an
executable. It can be asked to be considerably more helpful, and it is worth
doing so from the first day:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Option
     - Description
   * - ``-Wall``
     - Warns about constructions that are legal, but usually mistakes, such as
       an unused variable or a variable that is used before it is given a value.
   * - ``-std=f2018``
     - Rejects extensions that are not part of the Fortran 2018 standard, which
       keeps the code portable between compilers.
   * - ``-fcheck=all``
     - Adds checks that are performed while the program runs, for example that
       array indices are inside the bounds of the array.
   * - ``-g``
     - Includes debugging information in the executable, which is needed to run
       the program in a debugger.
   * - ``-O2``
     - Optimises the generated code. Used when the program is to be run for
       real, together with neither ``-fcheck=all`` nor ``-g``.

A reasonable command line while a program is being developed is::

   $ gfortran -Wall -std=f2018 -fcheck=all -g hello.f90 -o hello

The runtime checks and the debugging information make the program slower, so
they are removed and replaced with an optimisation option when the program is
used for production runs. :doc:`app_compiling_fortran` describes these and the
remaining options in more detail.

Programs in more than one file
==============================

A program is seldom kept in a single file. Procedures are normally placed in
modules, which are described in the chapter on the Fortran language. The
following module contains a single subroutine:

.. literalinclude:: ../../source/getting_started/greeting.f90
   :language: Fortran
   :linenos:

The main program uses the module and calls the subroutine:

.. literalinclude:: ../../source/getting_started/main.f90
   :language: Fortran
   :linenos:

Both files are given to the compiler on the same command line::

   $ gfortran greeting.f90 main.f90 -o greeting
   $ ./greeting
    Hello, Fortran!

The order matters. When the compiler reads ``greeting.f90`` it writes a file
``greeting.mod`` that describes the module, and that file has to exist before
``main.f90``, which uses the module, can be compiled. A module must therefore
always be compiled before the code units that use it.

For two files this is easy to keep track of. For twenty it is not, and it is
also wasteful to recompile everything when a single file has changed. That is
the problem the next section, and later the chapter
:doc:`chapter_fortran_projects`, is about.

Your first project with fpm
===========================

**fpm**, the Fortran Package Manager, is a build tool for Fortran projects. It
works out in which order the files have to be compiled, rebuilds only what is
affected by a change, runs the tests of a project and downloads the libraries a
project depends on. For a project that follows its directory layout, no build
files have to be written at all.

Installing fpm
--------------

.. tab-set::

   .. tab-item:: conda

      ::

         $ conda install -c conda-forge fpm

   .. tab-item:: macOS

      ::

         $ brew install fpm

   .. tab-item:: Binary

      Single-file executables for Linux, macOS and Windows are published for
      each release at
      `github.com/fortran-lang/fpm/releases <https://github.com/fortran-lang/fpm/releases>`_.
      Download the file for the platform, rename it to ``fpm`` (or ``fpm.exe``)
      and place it in a directory in the path.

Creating a project
------------------

The command **fpm new** creates a complete project::

   $ fpm new hello_fpm
   $ cd hello_fpm

The generated project contains a library source directory, a program, a test
and a configuration file::

   hello_fpm/
   |-- fpm.toml
   |-- README.md
   |-- app/
   |   `-- main.f90
   |-- src/
   |   `-- hello_fpm.f90
   `-- test/
       `-- check.f90

The directories have fixed meanings. ``src`` holds the modules that make up the
library part of the project, ``app`` holds main programs, and ``test`` holds
test programs. fpm finds the source files itself, so files can be added to these
directories without any configuration being changed.

``fpm.toml`` describes the project. The generated file is short:

.. code-block:: toml

   name = "hello_fpm"
   version = "0.1.0"
   license = "license"
   author = "Jane Doe"
   maintainer = "jane.doe@example.com"
   copyright = "Copyright 2026, Jane Doe"

   [fortran]
   implicit-typing = false
   implicit-external = false
   source-form = "free"

The ``[fortran]``-section is worth noting. With ``implicit-typing`` set to
false, fpm compiles the project as if every code unit contained an
**implicit none**, which is the behaviour recommended throughout this book.

Building and running
--------------------

Three commands cover most of the daily work::

   $ fpm build
   $ fpm run
    Hello, hello_fpm!
   $ fpm test

**fpm build** compiles everything that needs compiling, **fpm run** builds and
then runs the program in ``app``, and **fpm test** builds and runs the test
programs in ``test``. If a project contains more than one program, the name is
given as an argument, ``fpm run --target myprog``.

Options are passed on to the compiler with the ``--flag``-option::

   $ fpm build --flag "-Wall -std=f2018 -fcheck=all"

The two files from the previous section fit into this layout without
modification: ``greeting.f90`` is placed in ``src`` and ``main.f90`` in ``app``.
fpm then works out that the module has to be compiled first.

Using a library
---------------

A project that needs an external library declares it in ``fpm.toml`` and fpm
downloads and builds it during the next build. The following adds the Fortran
standard library, **stdlib**, to the project:

.. code-block:: toml

   [dependencies]
   stdlib = "*"

Other projects are referenced by their repository:

.. code-block:: toml

   [dependencies]
   toml-f = { git = "https://github.com/toml-f/toml-f" }

fpm is well suited to new projects. Existing projects, and projects that combine
Fortran with code written in other languages, are usually built with Make or
CMake instead. Both are covered in :doc:`chapter_fortran_projects`.

Choosing an editor
==================

Any text editor can be used to write Fortran, but an editor that understands the
language is a considerable help. Visual Studio Code with the extension **Modern
Fortran** provides syntax highlighting, and together with the language server
**fortls** also code completion, jump to definition and error markers while the
code is being written. fortls is installed with::

   $ pip install fortls

The chapter :doc:`chapter_qtcreator` describes an alternative environment, Qt
Creator, which is closer in appearance to commercial development environments
such as Microsoft Visual Studio.

Where to go from here
=====================

With a working compiler the next chapter, :doc:`chapter_fortran`, can be read
with a terminal open next to it. All the examples in the book are in the
``source``-directory of the book's repository and can be compiled with the
commands shown above.

The exercises in :doc:`app_exercises` can be worked through in parallel with the
chapters, and :doc:`app_compiling_fortran` contains a fuller description of the
compiler options that were only summarised here.
