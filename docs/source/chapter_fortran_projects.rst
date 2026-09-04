*************************
Managing Fortran projects
*************************

When projects get larger, compiling and maintenance issues can become
quite complex. Many projects also needs to be able to build on different
platforms and operating environments. Using simple shell scripts often
work when the projects are small. However, shell scripts often lack the
ability to handle compilation dependencies between source files,
requiring a complete rebuild of the project for each modification. Tools
such as CMake and Make can solve many of these problems efficiently.

Make
====

Make is a tool that can build software according to special rules
defined in a makefile. Make automatically handles dependencies between
source files and only rebuilds parts of the software that are affected
by the change.

A makefile consists of a series of rules, dependencies and actions. The
general syntax for a makefile is:

| target: [dependencies]
| system command

A simple rule to compress a file, myfile.txt, is shown below:

.. code-block:: Make

   myfile.gz: myfile.txt
       cat myfile.txt | gzip > myfile.gz

In this example a rule, ``myfile.gz``, is created to compress the file.
The rule depends on the file, ``myfile.txt``. The action for compressing
the file is shown in the second row. When you run the make command in
the directory the following output is shown:

::

   $ ls
   Makefile    myfile.txt
   $ make
   cat myfile.txt | gzip > myfile.gz
   $ ls
   Makefile    myfile.gz   myfile.txt

If make is run again it will recognise that the ``myfile.txt`` has not
been changed and not execute the action again.

::

   $ make
   make: 'myfile.gz' is up to date.

If the ``myfile.txt`` is changed, make will recognise this and run the
specified action again.

::

   $ touch myfile.txt
   $ make
   cat myfile.txt | gzip > myfile.gz
   $ 

Compiling code with make
------------------------

Using these rules a build system for compiling source code can be
implemented. To compile a simple Fortran application the are some steps
that needs to be done:

#. Compile the source files to an object files (.o).

#. Link the object files to an executable.

For a single source file 2 rules are needed. One rule for compiling the
source file to an object file and one rule for linking the object file
to an executable. A simple makefile for a single source file application
is shown below:

.. code-block:: Make

   myprog: myprog.o 
       gfortran myprog.o -o myprog

   myprog.o: myprog.f90 
       gfortran -c myprog.f90

In the above example the executable, ``myprog``, depends on the object
file ``myprog.o``. The second rule defines how the object file is
created from the source file, ``myprog.f90``, which is also listed as a
dependency for the rule. Running make on this makefile produces the
following output:

::

   $ ls
   Makefile    myprog.f90
   $ make
   gfortran -c myprog.f90
   gfortran myprog.o -o myprog

Make first creates the object file as this is a dependency for the
creating the executable. Next, the executable, ``myprog``, is created by
using the gfortran compiler to create an executable from the object
file. When
running make again, make will check for modifications and only execute
actions if necessary.

Using make on a single source file is perhaps not the most useful thing.
However, when compiling multiple files using make becomes more useful.
To extend our above example to multiple source files we add the needed
dependencies to the rule for building the executable, ``myprog``. We
also need an additional rule for building our additional sourcefile,
``mymodule.f90``.

.. code-block:: Make

   myprog: myprog.o mymodule.o
       gfortran myprog.o mymodule.o -o myprog

   myprog.o: myprog.f90 
       gfortran -c myprog.f90

   mymodule.o: mymodule.f90
       gfortran -c mymodule.f90

The interesting happens when the ``mymodule.f90`` file is updated:

::

   $ touch mymodule.f90 
   $ make
   gfortran -c mymodule.f90
   gfortran myprog.o mymodule.o -o myprog

Make detects the change in the ``mymodule.f90`` file and only compiles
this file. As the ``myprog.f90`` was not updated the existing object
file can be reused. This is why it is a good idea to use make in large
projects. Modifying a single source
file in a large application will only rebuild what is needed to satisfy
the dependencies.

Fortran 90 Module dependencies
------------------------------

One problem compiling Fortran 90 code and modules is module
dependencies. When compiling a module the compiler creates ``.mod``-files
which can be compared to automatically generated header files in C. When
compiling a module which uses another module the used module must be
compiled first, so that the ``.mod``-file is available for the compiler.

In the following exaple we have a program, ``module_main.f90``, which
uses the module ``truss`` in ``module_truss.f90``. If we update the
previous makefile we get the following makefile:

.. code-block:: Make

   myprog: module_main.o module_truss.o
       gfortran module_main.o module_truss.o -o myprog

   module_main.o: module_main.f90
       gfortran -c module_main.f90

   module_truss.o: module_truss.f90
       gfortran -c module_truss.f90

Running make produces the following output:

::

   $ make
   module_main.f90:3.5:

    use truss
        1
   Fatal Error: Can't open module file 'truss.mod' for reading at (1): No such file or directory
   make: *** [module_main.o] Error 1

The compiler complains that it is missing the ``.mod``-file,
``truss.mod``, to be able to compile main module. To solve this an
additional dependency, ``module_truss.o``, is added to the build rule.
This means that to build the ``module_main.o`` file the
``module_truss.o`` file must first be build. The updated make file is
shown below:

.. code-block:: Make

   myprog: module_main.o module_truss.o
       gfortran module_main.o module_truss.o -o myprog

   module_main.o: module_main.f90 module_truss.o
       gfortran -c module_main.f90

   module_truss.o: module_truss.f90
       gfortran -c module_truss.f90

Running make again will produce the desired results:

::

   $ make
   gfortran -c module_truss.f90
   gfortran -c module_main.f90
   gfortran module_main.o module_truss.o -o myprog

From the above output it can be seen that make figures out the
dependencies and builds ``module_truss.f90`` first which produces the
needed ``truss.mod`` which is needed when compiling the
``module_main.f90`` file.

Using variables in make
-----------------------

To specify explicit commands in the make file rules can make the
makefiles difficult to maintain. Too solve this, make supports variables
in the same way as in normal bash-scripts. To use the value of a
variable in the makefile, the name of the variable is enclosed in
``$( )``. In the following example, the variable, ``FC``, is used to
specify which compiler that is going to be used. The compiler flags are
specified in the ``FFLAGS`` variable and the name of the application
binary is specified in the ``EXECUTABLE`` variable. In this example a
special clean rule has been added to clean all build files generated
when compiling the application. In the rule the ``$(EXECUTABLE)``
variable is used to make the rule more generic.

.. code-block:: Make

   FC=gfortran
   FFLAGS=-c
   EXECUTABLE=myprog

   $(EXECUTABLE): myprog.o mymodule.o
       $(FC) myprog.o mymodule.o -o myprog

   myprog.o: myprog.f90 
       $(FC) $(FFLAGS) myprog.f90

   mymodule.o: mymodule.f90
       $(FC) $(FFLAGS) mymodule.f90
       
   clean:
       rm -rf *.o *.mod $(EXECUTABLE)

Running make produces the desired result, but with a more flexible make
file.

::

   $ make
   gfortran -c myprog.f90
   gfortran -c mymodule.f90
   gfortran myprog.o mymodule.o -o myprog

Internal macros
---------------

To create even more generic makefiles and rules, make also has some
useful internal macros that can be used. The most important internal
macros are:

+--------+------------------------------------------+
| ``$@`` | The target of the current rule executed. |
+--------+------------------------------------------+
| ``$^`` | Name of all prerequisites                |
+--------+------------------------------------------+
| ``$<`` | Name of the first prerequisite           |
+--------+------------------------------------------+

Using ``$^`` and ``$@`` a more generic build rule for linking our
application can be created

.. code-block:: Make

   FC=gfortran
   FFLAGS=-c
   EXECUTABLE=myprog

   $(EXECUTABLE): myprog.o mymodule.o
       $(FC) $^ -o $@
   # ...

Here, ``$^``, is used to list all prerequisites for this build,
``myprog.o`` and ``mymodule.o``. The ``$@``, denotes the current target
as the output file for the compiler, in this case ``$(EXECUTABLE)`` or
``myprog``.

The rules for compiling source code can also be updated in a similar
way:

.. code-block:: Make

   # ...
   myprog.o: myprog.f90 
       $(FC) $(FFLAGS) $< -o $@
   # ...

Here the ``$<`` variable denotes the first prerequisite, ``myprog.f90``.
The target macro, ``$@``, is also used to define the outputfile for the
compiler.

There are several more internal macros that can be used in makefiles.
For more information please see the GNU Make documenation [gnumake12]_.

Suffix rules
------------

If a project consists of a larger number of source files, a large number
of rules must be written. Make, solves this by implementing so called
explicit rules. These rules can be regarded as a recipy for how to go
from one extension, ``.f90``, to another, ``.o``. A explicit rule for
compiling a Fortran source file to an object file then becomes:

.. code-block:: Make

   FC=gfortran
   FFLAGS=-c
   EXECUTABLE=myprog

   # ...

   .f90.o:
       $(FC) $(FFLAGS) $< -o $@

This rule eliminates all the compilation rules used in the previous
sections and makes the makefile more compact. To make the explicit rules
work for compiling Fortran code, make needs to now which suffixes are
used for Fortran source code. This is done with the special rule
``.SUFFIXES``. The following example shows the completed makefile with
the suffix rule:

.. code-block:: Make

   FC=gfortran
   FFLAGS=-c
   EXECUTABLE=myprog

   $(EXECUTABLE): myprog.o mymodule.o
       $(FC) $^ -o $@

   .f90.o:
       $(FC) $(FFLAGS) $< -o $@
       
   clean:
       rm -rf *.o *.mod $(EXECUTABLE)

   .SUFFIXES: .f90 .f03 .f .F

Wildcard expansion and substitution
-----------------------------------

Some times it can be beneficial to create lists of files by using
wildcards. To do this in make, the ``$(wildcard ...)`` function can be
used. To create a list of f90 source files the following assignment can
be used:

.. code-block:: Make

   F90_FILES := $(wildcard *.f90)

Please note the ``:=`` assignment operator used in conjunction with make
function calls.

When we have a list of source files, a list of object-files can easily
be created by using the ``$(patsubst ...)`` function. This uses patterns
to substitute the file suffixes from .f90 to .o. The assignment
statement then becomes:

.. code-block:: Make

   OBJECTS := $(patsubst %.f90, %.o, $(F90_FILES))

The rule to link all object files into an executable then becomes:

.. code-block:: Make

   $(EXECUTABLE): $(OBJECTS)
       $(FC) $^ -o $@

This a much more generic rule, which can be reused for other projects
without any change.

Pattern rules
-------------

The suffix rules defined in the previous section are provided by GNU
make for compatibility with older makefiles. The recommended way of
implementing suffix rules is using so called pattern rules.

A pattern rules specifies a ”Recipe” for a rule that can handle multiple
targets of a specific type. Using the ``%`` operator in the target
specification to match filenames for which the generic rule will apply.
A rule to compile Fortran source code to object files is written using
pattern rules as follows:

.. code-block:: Make

   %.o: %.f90
       $(FC) $(FFLAGS) $< -o $@

This defines a recipe for make how to create an object-file from a .f90
source file. This rule is implicitly used when make encounters an
object-file (implicit pattern rule).

The completed makefile with wildcards and pattern rules is shown below:

.. code-block:: Make

   FC=gfortran
   FFLAGS=-c
   EXECUTABLE=myprog

   F90_FILES := $(wildcard *.f90)
   OBJECTS := $(patsubst %.f90, %.o, $(F90_FILES))

   $(EXECUTABLE): $(OBJECTS)   
       $(FC) $^ -o $@

   %.o: %.f90
       $(FC) $(FFLAGS) $< -o $@
       
   clean:
       rm -rf *.o *.mod $(EXECUTABLE)

Please note that when using pattern rules the ``.SUFFIXES`` rule is not
needed.

Even if the described makefile automatically can compile all source
files, dependencies between Fortran 90 modules are not handled. The
easiest way of handling module dependencies are to explicitly express
these dependencies in the make file. To illustrate this, consider the
following example:

myprog.f90
   Main Fortran program. Uses the mymodule module located in the
   mymodule.f90 source file.

mymodule.f90
   Module mymodule. Uses the myutils module in the myutils.f90 source
   file.

myutils.f90
   Module myutils. Self contained module without dependencies.

To build this example, we need to build myutils.f90 first as the
mymodule.f90 needs the myutils.mod file created when myutils.f90 is
compiled. To enable this dependency an additional rule is added to our
make file:

.. code-block:: Make

   mymodule.o: myutils.o

This tells make that the object-file mymodule.o depends on myutils.o and
makes sure that it will be built first. If we update the makefile in the
previous section to handle this it becomes:

.. code-block:: Make

   FC = gfortran
   FFLAGS = -c
   EXECUTABLE = myprog

   F90_FILES := $(wildcard *.f90)
   OBJECTS := $(patsubst %.f90, %.o, $(F90_FILES))

   $(EXECUTABLE): $(OBJECTS) $(MODFILES)
       $(FC) $^ -o $@
       
   mymodule.o: myutils.o

   %.o %.mod: %.f90
       $(FC) $(FFLAGS) $< -o $@
       
   clean:
       rm -rf *.o *.mod $(EXECUTABLE)

When executing this makefile with make, myutils.f90, will be the first
target to be built.

::

   $ make
   gfortran -c myutils.f90 -o myutils.o
   gfortran -c mymodule.f90 -o mymodule.o
   gfortran -c myprog.f90 -o myprog.o
   gfortran mymodule.o myprog.o myutils.o -o myprog

For more advanced make file use, the CMake tool is a better tool. CMake
is covered in the next section.

CMake
=====

When projects become large the time needed for maintaining the build
system increases. This is often due to the fact that different OS
environments needs to be handled in different ways and this has to be
included in the makefile. CMake is a tool that can generate targeted
makefiles and project files for most existing development environments.
CMake works by parsing special files, CMakeLists.txt, and generating the
needed makefiles and project files.

Compiling code with cmake
-------------------------

To use CMake, a CMakeLists.txt file has to be created. This is a normal
text files with special CMake statements in it. Usually this files
starts with a `cmake_minimum_required`. This prevents the CMakeLists.txt file to be used by a
too old cmake. The first actual statement is usually `project`-function defining
the name of the project.

.. code-block:: CMake

   cmake_minimum_required(VERSION 2.6)
   project(simple)

The name of the project is not the same as the executable but is used
when generating project files for development environments.

CMake by default does not support Fortran, so a special function,
`enable_language`-function is used to enable this:

.. code-block:: CMake

   enable_language(Fortran)

To create an executable the `add_executable`-function is used. This command takes an
executable name as the first argument and a list of source files.

.. code-block:: CMake

   add_executable(simple myprog.f90)

The completed CMakeLists.txt file then becomes:

.. code-block:: CMake

   cmake_minimum_required(VERSION 2.6)
   project(simple)
   enable_language(Fortran)

   add_executable(simple myprog.f90)

Now when we have a CMakeLists.txt file it is possible to run in the same
directory to create the needed makefiles to build the project:

::

   $ ls
   CMakeLists.txt  myprog.f90
   $ cmake .
   -- The C compiler identification is GNU 4.2.1
   -- The CXX compiler identification is Clang 4.0.0
   -- Checking whether C compiler has -isysroot
   -- Checking whether C compiler has -isysroot - yes
   -- Checking whether C compiler supports OSX deployment target flag
   -- Checking whether C compiler supports OSX deployment target flag - yes
   -- Check for working C compiler: /usr/bin/gcc
   -- Check for working C compiler: /usr/bin/gcc -- works
   -- Detecting C compiler ABI info
   -- Detecting C compiler ABI info - done
   -- Check for working CXX compiler: /usr/bin/c++
   -- Check for working CXX compiler: /usr/bin/c++ -- works
   -- Detecting CXX compiler ABI info
   -- Detecting CXX compiler ABI info - done
   -- The Fortran compiler identification is GNU
   -- Check for working Fortran compiler: /opt/local/bin/gfortran
   -- Check for working Fortran compiler: /opt/local/bin/gfortran  -- works
   -- Detecting Fortran compiler ABI info
   -- Detecting Fortran compiler ABI info - done
   -- Checking whether /opt/local/bin/gfortran supports Fortran 90
   -- Checking whether /opt/local/bin/gfortran supports Fortran 90 -- yes
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /Users/.../simple
   $ ls
   CMakeCache.txt      CMakeLists.txt      cmake_install.cmake
   CMakeFiles      Makefile        myprog.f90

As show in the above output, cmake, has generated a lot of files one of
them being a normal makefile. To build the project, the normal make
command can be used.

::

   $ make
   Scanning dependencies of target simple
   [100%] Building Fortran object CMakeFiles/simple.dir/myprog.f90.o
   Linking Fortran executable simple
   [100%] Built target simple

CMake generates a lot of files when run. Which can make the source tree
quite cluttered. The recommended way of running CMake is to create a
separate build directory and generate the build files in this directory.
This is done in the following example:

::

   $ mkdir build
   $ cd build
   $ cmake ..
   -- The C compiler identification is GNU 4.2.1
   .
   .
   -- Generating done
   -- Build files have been written to: /Users/.../simple/build

Make is then run in this directory as before. In this approach it is
easy to remove the build files by removing the build directory.

Building debug and release versions
-----------------------------------

By default CMake generates build files for compiling debug versions of
an applicaiton. That is using no optimisation and with debug symbols.
Controlling the build type can be done by assigning the
``CMAKE_BUILD_TYPE`` variable to either ``Debug`` or ``Release`` when
executing CMake. Variables can be set on the command line by using the
switch ``-D`` as shown in the following example:

::

   $ cmake -D CMAKE_BUILD_TYPE=Release ..
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /Users/lindemann/Development/progsci_book/source/cmake_examples/simple/build

Adding library dependencies
---------------------------

In the previous examples the binaries have been built without any
library dependencies. To add link dependencies, the
``target_link_libraries``-function can be used. To add the libraries,
``blas`` and ``m``, as dependencies of the executable, the CMakeList.txt
becomes:

.. code-block:: CMake

   cmake_minimum_required(VERSION 2.6)
   project(simple)
   enable_language(Fortran)

   add_executable(simple myprog.f90)
   target_link_libraries(simple blas m)

To show what switches that are actually used when building the
executable, the `CMAKE_VERBOSE_MAKEFILE`, is set to `ON`. This will show the actual commands used
during the build.

::

   $ mkdir build
   $ cd build/
   $ cmake -D CMAKE_VERBOSE_MAKEFILE=ON ..
   -- The C compiler identification is GNU 4.2.1
   -- The CXX compiler identification is Clang 4.0.0
   ...
   -- Generating done
   -- Build files have been written ...
   $ make
   ...
   /opt/local/bin/gfortran [...]/mymodule.f90.o  -o multiple  -lblas -lm 
   ...

Which shows that the libraries have been added to the actual compilation
command.

Variables and conditional builds
--------------------------------

Often when compiling code under different platforms, special flags and
commands have to be used. CMake supports conditional statements in the
CMakeLists.txt files to handle these cases. To test for a Unix-build the
following if statement can be used:

.. code-block:: CMake

   if (UNIX)
       message("This is a Unix build.")
   endif (UNIX)

`UNIX` is a predefined variable that is true when building on Unix-type system.
When running CMake on a Unix-type system will print ”This is a Unix
build.” on the console.

CMake also has an else-statement. The following code, creates a build
target and adds different build options depending on the platform used:

.. code-block:: CMake

   if (UNIX)
       add_executable(multiple myprog.f90 mymodule.f90)
       target_link_libraries(multiple blas m)
   else (UNIX)
       if (WIN32)
           add_executable(multiple myprog.f90 mymodule.f90)
           target_link_libraries(multiple blas32)
       else (WIN32)
           message("Not supported configuration.")
       endif (WIN32)
   endif (UNIX)

It is also possible to use variables in CMake. Variables can be both
strings and lists of strings. A variable is created by using the
`set`-function. The following example shows how a simple string variable is
created:

.. code-block:: CMake

   set(MYVAR "Hello, world!")

To use the actual value of a variable, it has to be preceded by a $
enclosed by curly brackets as shown in the following example:

.. code-block:: CMake

   set(MYVAR "Hello, world!")
   message(${MYVAR})

This will print the contents of the variable, ``MYVAR``. If not enclosed
it will print the name of the variable.

Variables can also be lists of values which can be iterated over.
Creating a list is also done using the `set`-function, as shown in this
example:

.. code-block:: CMake

   set(MYLIST a b c)
   message(${MYLIST})

Here, the list ``MYLIST`` is created, containing 3 strings. The
``message``-function will concatenate the items in the list and the
resulting output of running cmake will be:

::

   $ cmake ..
   abc
   -- Configuring done
   -- Generating done
   -- Build files have been written to: ...

Using a list variable it is also possible to do an iteration using a
``foreach``-statement, which the following example shows:

::

   set(MYLIST a b c)
   foreach(i ${MYLIST})
       message(${i})
   endforeach(i)

Running this using CMake produced the following output:

::

   $ cmake ..
   a
   b
   c
   -- Configuring done
   -- Generating done
   -- Build files have been written to: ...

Controlling optimisation options
--------------------------------

Optimisation options can differ between compilers. To control the
optimisation options in CMake, conditional builds using if-statements
can be used. First, the used compiler needs to be queried. The path to
the actual compiler is stored in the ``CMAKE_Fortran_COMPILER``
variable. To create an if-statement on the compiler the compiler command
must be extracted from the compiler path. This can be accomplished using
the ``get_filename_component``-function:

.. code-block:: CMake

   get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)

This command extracts the filename component of the path and stores it
in the variable ``Fortran_COMPILER_NAME``. Next, an if-statement has to
implemented that queries for different compilers. A string comparison
can be done using the ``STREQUAL`` operator in CMake. Compilation flags
for CMake are stored in ``CMAKE_Fortran_FLAGS_RELEASE`` for release mode
flags and ``CMAKE_Fortran_FLAGS_DEBUG`` for debug flags. An example of
this kind of conditional compilation statement is shown below (from
[cmakecond12]_):

.. code-block:: CMake

   if (Fortran_COMPILER_NAME STREQUAL "gfortran")
     set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3")
     set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -g")
   elseif (Fortran_COMPILER_NAME STREQUAL "ifort")
     set (CMAKE_Fortran_FLAGS_RELEASE "-f77rtl -O3")
     set (CMAKE_Fortran_FLAGS_DEBUG   "-f77rtl -O0 -g")
   elseif (Fortran_COMPILER_NAME STREQUAL "g77")
     set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3 -m32")
     set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -g -m32")
   else (Fortran_COMPILER_NAME STREQUAL "gfortran")
     message ("No optimized Fortran compiler flags are known, we just try -O2...")
     set (CMAKE_Fortran_FLAGS_RELEASE "-O2")
     set (CMAKE_Fortran_FLAGS_DEBUG   "-O0 -g")
   endif (Fortran_COMPILER_NAME STREQUAL "gfortran")

Generating project files for development environments
-----------------------------------------------------

CMake is not limited to generating makefiles, it can also generate
project files for a number of graphical development environments.
Supported generators in CMake can be listed by running the
``cmake``-command without parameters. The following list is produced on a Mac OS X based
machine:

Generators

   The following generators are available on this platform:
     Unix Makefiles = Generates standard UNIX makefiles.
     Xcode          = Generate Xcode project files.
     CodeBlocks - Unix Makefiles = Generates CodeBlocks project files.
     Eclipse CDT4 - Unix Makefiles = Generates Eclipse CDT 4.0 project files.
     KDevelop3      = Generates KDevelop 3 project files.
     KDevelop3 - Unix Makefiles  = Generates KDevelop 3 project files.

This lists covers most common development environments for Mac OS X.
When running on a Windows machine, generators for Visual Studio and
other development environments for that platform will be available as
well.

To generate build files for a different generator the ``-G``-switch is
used. In the following example build files for the Eclipse-environment
are generated.

::

   $ mkdir build_eclipse
   $ cd build_eclipse/
   $ cmake -G "Eclipse CDT4 - Unix Makefiles" ../multiple/
   -- The C compiler identification is GNU 4.2.1
   -- The CXX compiler identification is Clang 4.0.0
   -- Could not determine Eclipse version, assuming at least 3.6 (Helios). Adjust CMAKE_ECLIPSE_VERSION if this is wrong.
   ...
   -- Generating done
   -- Build files have been written to: ...
   $ ls -la
   total 112
   drwxr-xr-x   8 lindemann  staff    272 Aug 29 20:07 .
   drwxr-xr-x  13 lindemann  staff    442 Aug 29 20:06 ..
   -rw-r--r--   1 lindemann  staff  14343 Aug 29 20:07 .cproject
   -rw-r--r--   1 lindemann  staff   5527 Aug 29 20:07 .project
   -rw-r--r--   1 lindemann  staff  17808 Aug 29 20:07 CMakeCache.txt
   drwxr-xr-x  21 lindemann  staff    714 Aug 29 20:07 CMakeFiles
   -rw-r--r--   1 lindemann  staff   4770 Aug 29 20:07 Makefile
   -rw-r--r--   1 lindemann  staff   1562 Aug 29 20:07 cmake_install.cmake

When generation is completed this directory can be added to a Eclipse
workspace as a project.

Please note that in the above example we are using a build directory not
located in the source tree. This is the recommended way for an Eclipse
based project.

fpm - the Fortran Package Manager
=================================

Make and CMake are general build tools that happen to know about Fortran. **fpm**, the Fortran Package Manager, is the opposite: it knows only about Fortran, and because of that it needs almost no configuration. It works out the compilation order from the **use**-statements in the source, rebuilds only what a change affects, runs the project's tests, and fetches the libraries the project depends on.

The chapter :doc:`chapter_getting_started` shows how to create and run a first project with **fpm new**. This section covers the manifest and the parts that matter once a project grows.

The project layout
------------------

fpm finds source files by their location, so the directory names are part of the interface:

::

   myproject/
   |-- fpm.toml
   |-- app/          main programs, one executable per program
   |-- src/          modules, compiled into the project library
   |-- test/         test programs, run by fpm test
   |-- example/      example programs, run by fpm run --example
   `-- build/        everything fpm generates, safe to delete

Files added to these directories are picked up without any change to the manifest. A module in ``src`` that is used by a program in ``app`` is compiled first, without a rule being written anywhere.

The manifest
------------

``fpm.toml`` is written in TOML and is short for most projects:

.. code-block:: toml

   name = "myproject"
   version = "0.1.0"
   license = "MIT"
   author = "Jane Doe"
   maintainer = "jane.doe@example.com"

   [build]
   auto-executables = true
   auto-tests = true

   [install]
   library = false

   [fortran]
   implicit-typing = false
   implicit-external = false
   source-form = "free"

The ``[fortran]``-section is worth setting deliberately. With ``implicit-typing = false`` fpm compiles the whole project as if every code unit contained an **implicit none**, which is the rule the first chapter recommends, applied to the project rather than one file at a time.

Targets can also be declared explicitly, which is needed when a program's file name and the executable name differ, or when a test needs a name of its own:

.. code-block:: toml

   [[executable]]
   name = "solver"
   source-dir = "app"
   main = "solver_main.f90"

   [[test]]
   name = "unit-tests"
   source-dir = "test"
   main = "check.f90"

Dependencies
------------

A dependency is one entry in the manifest, and fpm downloads and builds it on the next build. Nothing has to be installed on the machine first.

.. code-block:: toml

   [dependencies]
   stdlib = "*"
   toml-f = { git = "https://github.com/toml-f/toml-f" }
   test-drive = { git = "https://github.com/fortran-lang/test-drive", tag = "v0.4.0" }
   mylib = { path = "../mylib" }

The four forms are, in order: a package from the central registry, a git repository at its default branch, a git repository pinned to a tag, and a directory on the same machine, which is how a project under development is used before it is published. Pinning to a tag or a commit is worth doing for anything that a build has to reproduce later.

Dependencies that only the tests need go in a separate section, so that they are not built for an ordinary build:

.. code-block:: toml

   [dev-dependencies]
   test-drive = { git = "https://github.com/fortran-lang/test-drive" }

Building, testing and installing
--------------------------------

::

   $ fpm build                       # compile what needs compiling
   $ fpm run                         # build, then run the program in app
   $ fpm run --target solver -- -v   # a named program, with its own arguments
   $ fpm test                        # build and run everything in test
   $ fpm install --prefix ~/.local   # copy the executables somewhere permanent

By default fpm builds without optimisation, which is what is wanted while code is being written. For a build meant to be run in earnest::

   $ fpm build --profile release

Individual compiler options are passed with ``--flag``, which replaces the profile's options rather than adding to them::

   $ fpm build --flag "-Wall -std=f2018 -fcheck=all -g"

Which tool to use
-----------------

fpm is the shortest path from nothing to a built and tested project, and for a new project written entirely in Fortran there is little reason to use anything else. Its limits are the other side of the same coin: a project that mixes Fortran with C or C++, that has to produce a library other build systems consume, or that depends on how a particular platform is configured, is better served by CMake. Make remains worth understanding because both of the others generate makefiles, and because a build that goes wrong is usually debugged one rule at a time.

The Fortran standard library
============================

Fortran's intrinsic procedures cover arithmetic and arrays and very little else. There is no sort, no string splitting, no reading a table of numbers from a file, no random number generator worth the name. Every project has therefore had to write the same few hundred lines, and every project has written them slightly differently.

**stdlib**, the Fortran standard library, is the community's answer to that. It is a single library of the routines that keep being rewritten, developed at `github.com/fortran-lang/stdlib <https://github.com/fortran-lang/stdlib>`_, and parts of it are proposals for a future Fortran standard.

The easiest way to use it is as an fpm dependency:

.. code-block:: toml

   [dependencies]
   stdlib = "*"

It can also be installed with conda, ``conda install -c conda-forge fortran-stdlib``, and built with CMake for projects that use it.

The library is organised as a set of modules, each with a ``stdlib_`` prefix:

.. csv-table::
    :header: "Module", "Contents"

    "stdlib_kinds", "sp, dp, qp, int8 ... int64, the kind names used throughout the library"
    "stdlib_math", "linspace, logspace, arange, clip, gcd"
    "stdlib_stats", "mean, var, moment, median, corr, cov"
    "stdlib_linalg", "eye, diag, trace, det, inv, solve, lstsq, eigvals"
    "stdlib_sorting", "sort, ord_sort, sort_index"
    "stdlib_strings", "to_lower, to_upper, replace_all, starts_with, slice"
    "stdlib_str2num", "to_num, converting a string to a number"
    "stdlib_io", "loadtxt, savetxt, open, getline"
    "stdlib_error", "check, error_stop"
    "stdlib_logger", "a logger with severity levels, writing to a file or the console"
    "stdlib_random", "dist_rand, and distributions in stdlib_stats_distribution_*"

A program that reads a table of numbers, sorts a column and prints some statistics is a few lines rather than a few hundred:

.. code-block:: Fortran

    program summary

        use stdlib_kinds, only: dp
        use stdlib_io, only: loadtxt
        use stdlib_stats, only: mean, var
        use stdlib_sorting, only: sort

        implicit none

        real(dp), allocatable :: table(:,:), column(:)

        call loadtxt('measurements.txt', table)

        column = table(:,1)
        call sort(column)

        write(*,*) 'n        =', size(column)
        write(*,*) 'median   =', column(size(column)/2 + 1)
        write(*,*) 'mean     =', mean(column)
        write(*,*) 'variance =', var(column)

    end program summary

The library is under active development, and its own documentation at `stdlib.fortran-lang.org <https://stdlib.fortran-lang.org>`_ is the place to check what a routine's interface currently is. Not everything in it is stable yet, which is a reason to pin the version a project depends on rather than tracking the default branch.

Testing Fortran code
====================

Numerical code is unusually easy to get subtly wrong and unusually hard to eyeball. A routine that returns a plausible number for a plausible input can be wrong by a factor of two in a corner that nobody looks at, and the wrongness only surfaces when someone tries to publish the results. A test is what turns "it seemed to work" into something that is checked again every time the code is touched.

A test is nothing more than a program that computes something whose answer is known and stops with a nonzero exit status if the answer is wrong. The **error stop**-statement from the language chapter is all that is strictly needed.

The module below is the thing being tested:

.. literalinclude:: ../../source/testing/stats.f90
   :language: Fortran
   :linenos:

and this is a test program for it:

.. literalinclude:: ../../source/testing/check_stats.f90
   :language: Fortran
   :linenos:

::

   $ gfortran stats.f90 check_stats.f90 -o check_stats
   $ ./check_stats
    ok: mean of the sample
    ok: variance of the sample
    ok: mean of one element
    all tests passed
   $ echo $?
   0

Two details in the test are worth copying. Floating point results are compared against a tolerance rather than with ``==``, because two calculations that are mathematically equal are rarely bit-identical. And the failure message names which check failed, since a test that only says "failed" sends the reader back to the source to find out what it was testing.

Placing the file in the ``test`` directory of an fpm project is enough for fpm to build and run it::

   $ fpm test
   ok: mean of the sample
   ok: variance of the sample
   ok: mean of one element
   all tests passed

**fpm test** reports a failure if any test program exits with a nonzero status, which is exactly what **error stop** produces.

Test frameworks
---------------

Hand-written checks stop scaling at a few dozen tests, because a program that stops at the first failure only reports one problem per run. A test framework collects the tests, runs all of them, and reports the failures together.

`test-drive <https://github.com/fortran-lang/test-drive>`_ is the one most commonly used with fpm, and is a dev-dependency of many fortran-lang projects:

.. code-block:: toml

   [dev-dependencies]
   test-drive = { git = "https://github.com/fortran-lang/test-drive" }

Tests are written as subroutines that are collected into a suite, and the framework provides a **check** routine for the assertions:

.. code-block:: Fortran

    subroutine test_mean(error)

        use testdrive, only: error_type, check

        type(error_type), allocatable, intent(out) :: error

        call check(error, mean([2.0_dp, 4.0_dp, 6.0_dp]), 4.0_dp, thr=1.0e-12_dp)

    end subroutine test_mean

Other frameworks exist — **pFUnit**, which is built around MPI-parallel codes, and **veggies** are the two seen most often — but for a project already using fpm, test-drive involves the least machinery.

Running the tests automatically
-------------------------------

Tests that are only run when someone remembers to run them stop being run. Both GitHub and GitLab can build a project and run its tests on every push, and for an fpm project the configuration is short. A GitHub Actions workflow needs a file in ``.github/workflows``:

.. code-block:: yaml

   name: tests

   on: [push, pull_request]

   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: fortran-lang/setup-fpm@v5
         - run: fpm test --flag "-Wall -std=f2018 -fcheck=all"

The runtime checks are worth enabling here even though they slow the tests down. A test suite is exactly where an out of bounds array access should be caught, and it is the one place where the cost does not matter.
