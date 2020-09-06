********************************************
Appendix 2 - Quick Fortran compilation guide
********************************************

This chapters is a quick guide on how to compile simple Fortran
application needed for the exercises in this book. The examples uses the
gfortran compiler.

Compiling single source Fortran programs
========================================

To compile a simple Fortran 90 source file into an executable, execute
the -command with the source file as the only argument:

.. code-block::

   $ ls
   myprog.f90
   $ gfortran myprog.f90 
   $ ls
   a.out       myprog.f90

This produces an executable called , which can be executed using the
following command:

.. code-block:: 

   $ ./a.out 
    Hello, World!

By default, the name of the executable will be , which is not always the
best name for an executable. To tell the compiler to name the executable
to something more meaningful the command line switch, , can be used as
shown in the following example:

.. code-block:: 

   $ gfortran myprog.f90 -o myprog
   $ ls
   myprog      myprog.f90
   $ ./myprog 
    Hello, World!

Compiling multi-source Fortran programs
=======================================

Often a Fortran application consists of multiple source files. To
compile multiple source files, gfortran supports adding additional
source files as parameters on the command line as shown below:

.. code-block::

   $ gfortran mymodule.f90 myprog.f90 -o myprog
   $ ls
   mymodule.f90    mymodule.mod    myprog      myprog.f90
   $ ./myprog 
    Hello, World!

However, the order of the source files are important. If a module
depends on a another module the dependent module needs to be built first
as the first module uses a special -file generated during the
compilation.

Compiling with optimisation levels
==================================

By default, gfortran, does not optimise the generated code in anyway. To
increase performance optimisation options must be specified. There are 3
levels default optimisation available in the , and compiler command line
options.

-  O1 - Tries to reduce code size and execution time, but without
   increasing compilation time.

-  O2 - Adds allmost all optimisation that does not increase the code
   size. No loop unrolling is done.

-  O3 - Applies all optimisation options even those that increases code
   size. Loop unrolling is done.

To compile with optimisation just add the above options as the first
option to the compiler command as shown in the following example:

.. code-block:: 

   $ gfortran -O3 mymodule.f90 myprog.f90 -o myprog

Compiling for debugging
=======================

To debug a compiled executable using gdb or a graphical debugger, the
executable needs to have debugging information included in the binary.
By default gfortran does not add any debugging information in the
executable. To tell the compiler to include this in the binary, the
-switch must be used. The following commands show how a debug enabled
executable is built:

.. code-block::

   $ gfortran -g mymodule.f90 myprog.f90 -o myprog

It is possible to add debug information to an optimised code as well.
However, the execution path of an optimised executable is not always
obvious. It is also possible that certain variables have been eliminated
by the optimisation options of the compiler.

Compiling with more detailed code checking
==========================================

Gfortran by default does not report all code issues in the source code.
The level of code checks can be increased by using the or switches. The
option warns of the use of extensions to the used Fortran standard (by
default Fortran 95). Can also be used together with the switches, , and
to check for extension to other Fortran standards. In the below example
the code is compiled with the option:

.. code-block:: 

   $ gfortran -pedantic mymodule.f90 myprog.f90 -o myprog
   myprog.f90:3.1:

    implicit none
    1
   Warning: Nonconforming tab character at (1)
   myprog.f90:5.1:

    print*, 'Hello, World!'
    1
   Warning: Nonconforming tab character at (1)

In the above example, gfortran complains about the use of a
tab-character in the source files. The tab-character is not part of the
Fortran standard.

The switch tells the compiler to check for code practices that should be
avoided. The example below shows how it can be used:

.. code-block::

   $ gfortran -Wall mymodule.f90 myprog.f90 -o myprog
   myprog.f90:3.1:

    implicit none
    1
   Warning: Nonconforming tab character at (1)
   myprog.f90:5.1:

    print*, 'Hello, World!'
    1
   Warning: Nonconforming tab character at (1)

Compiling with runtime checks
=============================

Some application errors can not be detected at compile time. To check
for these errors, gfortran can add checks in the executable for these.
To enable a certain check the -switch can be used to enable specific
checks. Common checks are:

 -  Accessing array elements outside its bounds.
 -  Modification of loop variables.
 -  Memory allocation and deallocation.
 -  Runtime checks for pointer handling.
 -  Check for when an array-temporary has to be created for passing an
   argument.
 -  Add all available runtime checks.

It is important to remove these checks in the final code as they add an
additional overhead in the execution speed.
