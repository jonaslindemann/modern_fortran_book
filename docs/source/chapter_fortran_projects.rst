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

In this example a rule, , is created to compress the file. The rule
depends on the file, . The action for compressing the file is shown in
the second row. When you run the make command in the directory the
following output is shown:

::

   $ ls
   Makefile    myfile.txt
   $ make
   cat myfile.txt | gzip > myfile.gz
   $ ls
   Makefile    myfile.gz   myfile.txt

If make is run again it will recognise that the has not been changed and
not execute the action again.

::

   $ make
   make: 'myfile.gz' is up to date.

If the is changed, make will recognise this and run the specified action
again.

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

In the above example the executable, , depends on the object file . The
second rule defines how the object file is created from the source file,
, which is also listed as a dependency for the rule. Running make on
this makefile produces the following output:

::

   $ ls
   Makefile    myprog.f90
   $ make
   gfortran -c myprog.f90
   gfortran myprog.o -o myprog

Make first creates the object file as this is a dependency for the
creating the executable. Next, the executable, , is created by using the
gfortran compiler to create an executable from the object file. When
running make again, make will check for modifications and only execute
actions if necessary.

Using make on a single source file is perhaps not the most useful thing.
However, when compiling multiple files using make becomes more useful.
To extend our above example to multiple source files we add the needed
dependencies to the rule for building the executable, . We also need an
additional rule for building our additional sourcefile, .

.. code-block:: Make

   myprog: myprog.o mymodule.o
       gfortran myprog.o mymodule.o -o myprog

   myprog.o: myprog.f90 
       gfortran -c myprog.f90

   mymodule.o: mymodule.f90
       gfortran -c mymodule.f90

The interesting happens when the file is updated:

::

   $ touch mymodule.f90 
   $ make
   gfortran -c mymodule.f90
   gfortran myprog.o mymodule.o -o myprog

Make detects the change in the file and only compiles this file. As the
was not updated the existing object file can be reused. This is why it
is a good idea to use make in large projects. Modifying a single source
file in a large application will only rebuild what is needed to satisfy
the dependencies.

Fortran 90 Module dependencies
------------------------------

One problem compiling Fortran 90 code and modules is module
dependencies. When compiling a module the compiler creates -files which
can be compared to automatically generated header files in C. When
compiling a module which uses another module the used module must be
compiled first, so that the -file is available for the compiler.

In the following exaple we have a module, , which uses . If we update
the previous makefile we get the following makefile:

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

The compiler complains that it is missing the -file, , to be able to
compile main module. To solve this an additional dependency, , is added
to the build rule. This means that to build the file the file must first
be build. The updated make file is shown below:

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
dependencies and builds the first which produces the needed which is
needed when compiling the file.

Using variables in make
-----------------------

To specify explicit commands in the make file rules can make the
makefiles difficult to maintain. Too solve this, make supports variables
in the same way as in normal bash-scripts. To use the value of a
variable in the makefile, the name of the variable is enclosed in . In
the following example, the variable, , is used to specify which compiler
that is going to be used. The compiler flags are specified in the
variable and the name of the application binary is specified in the
variable. In this example a special clean rule has been added to clean
all build files generated when compiling the application. In the rule
the is used to make the rule more generic.

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
   ...

Here, ``$^``, is used to list all prerequisites for this build, . The
``$@``, denotes the current target as the output file for the compiler,
in this case or .

The rules for compiling source code can also be updated in a similar
way:

.. code-block:: Make

   ...
   myprog.o: myprog.f90 
       $(FC) $(FFLAGS) $< -o $@
   ...

Here the ``$<`` variable denotes the first prerequisite, . The target
macro, ``$@``, is also used to define the outputfile for the compiler.

There are several more internal macros that can be used in makefiles.
For more information please see the GNU Make documenation
:raw-latex:`\cite{gnumake12}`.

Suffix rules
------------

If a project consists of a larger number of source files, a large number
of rules must be written. Make, solves this by implementing so called
explicit rules. These rules can be regarded as a recipy for how to go
from one extension, to another . A explicit rule for compiling a Fortran
source file to an object file then becomes:

.. code-block:: Make

   FC=gfortran
   FFLAGS=-c
   EXECUTABLE=myprog

   ...

   .f90.o:
       $(FC) $(FFLAGS) $< -o $@

This rule eliminates all the compilation rules used in the previous
sections and makes the makefile more compact. To make the explicit rules
work for compiling Fortran code, make needs to now which suffixes are
used for Fortran source code. This is done with the special rule . The
following example shows the completed makefile with the suffix rule:

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
be created by using the function. This uses patterns to substitute the
file suffixes from .f90 to .o. The assignment statement then becomes:

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

Please note that when using pattern rules the is not needed.

Even if the described makefile automatically can compile all source
files, dependencies between Fortran 90 modules are not handled. The
easiest way of handling module dependencies are to explicitly express
these dependencies in the make file. To illustrate this, consider the
following example:

myprog.f90
   Main fortran program. Uses the mymodule module located in the
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
starts with a . This prevents the CMakeLists.txt file to be used by a
too old cmake. The first actual statement is usually -function defining
the name of the project.

.. code-block:: CMake

   cmake_minimum_required(VERSION 2.6)
   project(simple)

The name of the project is not the same as the executable but is used
when generating project files for development environments.

CMake by default does not support Fortran, so a special function,
-function is used to enable this:

.. code-block:: CMake

   enable_language(Fortran)

To create an executable the -function is used. This command takes an
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
Controlling the build type can be done by assigning the variable to
either or when executing CMake. Variables can be set on the command line
by using the switch -D as shown in the following example:

::

   $ cmake -D CMAKE_BUILD_TYPE=Release ..
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /Users/lindemann/Development/progsci_book/source/cmake_examples/simple/build

Adding library dependencies
---------------------------

In the previous examples the binaries have been built without any
library dependencies. To add link dependencies, the can be used. To add
the libraries, and as dependencies of the executable, the CMakeList.txt
becomes:

.. code-block:: CMake

   cmake_minimum_required(VERSION 2.6)
   project(simple)
   enable_language(Fortran)

   add_executable(simple myprog.f90)
   target_link_libraries(simple blas m)

To show what switches that are actually used when building the
executable, the , is set to . This will show the actual commands used
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

is predefined variable that is true when building on Unix-type system.
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
-function. The following example shows how a simple string variable is
created:

.. code-block:: CMake

   set(MYVAR "Hello, world!")

To use the actual value of a variable, it has to be preceded by a $
enclosed by curly brackets as shown in the following example:

.. code-block:: CMake

   set(MYVAR "Hello, world!")
   message(${MYVAR})

This will print the contents of the variable, . If not enclosed it will
print the name of the variable.

Variables can also be lists of values which can be iterated over.
Creating a list is also done using the -function, as shown in this
example:

.. code-block:: CMake

   set(MYLIST a b c)
   message(${MYLIST})

Here, , containing 3 strings. The -function will concatenate the items
in the list and the resulting output of running cmake will be:

::

   $ cmake ..
   abc
   -- Configuring done
   -- Generating done
   -- Build files have been written to: ...

Using a list variable it is also possible to do an iteration using a
-statement, which the following example shows:

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
the actual compiler is stored in the . To create an if-statement on the
compiler the compiler command must be extracted from the compiler path.
This can be accomplished using the

.. code-block:: CMake

   get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)

This command extracts the filename component of the path and stores it
in the variable . Next, an if-statement has to implemented that queries
for different compilers. A string comparison can be done using the
operator in CMake. Compilation flags for CMake are stored in for release
mode flags and for debug flags. An example fo this king of conditional
compilation statement is shown below (from
:raw-latex:`\cite{cmakecond12}`):

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
Supported generators in CMake can be listed by running the -command
without parameters. The following list is produced on a Mac OS X based
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

To generate build files for a different generator the -switch is used.
In the following example build files for the Eclipse-environment are
generated.

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

