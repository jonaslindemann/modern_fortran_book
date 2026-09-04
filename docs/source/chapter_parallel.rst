********************
Parallel programming
********************

A single processor core has not become much faster for a long time. What has
grown instead is the number of cores, and a program that uses one of them
leaves most of the machine idle. Fortran has three ways of using the rest, and
they sit at different levels: **do concurrent** is part of the language and
says only that a loop may be run in any order, **OpenMP** is a set of
directives for sharing work between threads inside one process, and
**coarrays** are part of the language and describe a program that runs as
several independent copies of itself.

This chapter introduces all three. It is not a complete treatment of any of
them, but enough to write a first parallel program and to know which of the
three to reach for.

do concurrent
=============

The ordinary **do**-statement is defined to run its iterations one after the
other, in order. Even when the iterations do not depend on each other, a
compiler has to prove that before it can reorder them, and for anything but the
simplest loop body it cannot.

**do concurrent**, introduced in Fortran 2008, is how the programmer says it
instead. The syntax resembles a **forall**-statement:

.. code-block:: Fortran

    do concurrent (index = start:stop [:step] [, mask])
        block
    end do

The following example fills one array and then takes the square root of every
second element:

.. literalinclude:: ../../source/do_concurrent/concurrent.f90
   :language: Fortran
   :linenos:

The program prints:

::

     1    1.0000    0.0000
     2    2.0000    1.4142
     3    3.0000    0.0000
     4    4.0000    2.0000
     5    5.0000    0.0000
     6    6.0000    2.4495
     7    7.0000    0.0000
     8    8.0000    2.8284

The second construct carries a mask, ``mod(i, 2) == 0``, so only the even
iterations are executed. Note that the odd elements of ``y`` keep the value
they were given before the loop; a masked **do concurrent** does not touch the
iterations the mask excludes.

What the programmer promises
----------------------------

**do concurrent** is a promise, and the compiler takes it at its word. Writing
it means that the iterations can be executed in any order, or all at the same
time, and still produce the same result. If that is not true the program is
invalid, and it will usually not fail loudly — it will produce a slightly
different answer on a different machine, or on the same machine on a different
day.

In practice this rules out:

- writing to a variable in one iteration and reading it in another,
- accumulating into a scalar, such as ``total = total + x(i)``,
- **exit** and **cycle** out of the construct,
- calling a procedure that is not **pure**, since a procedure with side
  effects is by definition order dependent.

Accumulating into a scalar is the case that catches most people. A sum is
exactly what **do concurrent** cannot express, and is what OpenMP's reduction
clause, later in this chapter, exists for.

Fortran 2018 adds locality specifiers, which state per variable whether it is
private to an iteration or shared between them:

.. code-block:: Fortran

    do concurrent (i = 1:n) local(tmp) shared(a, b) default(none)
        tmp = b(i)*b(i)
        a(i) = tmp + 1.0
    end do

``default(none)`` forces every variable in the construct to be listed, in the
same spirit as **implicit none**. Support for locality specifiers is recent, so
check that the compiler in use accepts them before relying on them.

What the compiler actually does
-------------------------------

It is worth being clear that **do concurrent** does not by itself make anything
run in parallel. The standard only grants permission; whether the compiler
takes it is a quality-of-implementation question, and the answer differs
between compilers and between versions of the same compiler.

- gfortran generates serial code for **do concurrent** unless
  auto-parallelisation is enabled with ``-ftree-parallelize-loops=N``.
- The Intel compiler, ``ifx``, and the NVIDIA compiler, ``nvfortran``, can map
  a **do concurrent** construct onto threads, and ``nvfortran`` can map it onto
  a GPU with ``-stdpar=gpu``.

So the construct is worth writing for what it documents even when the current
compiler ignores it. It states an assumption that would otherwise live only in
the programmer's head, and it costs nothing.

OpenMP
======

OpenMP is not part of the Fortran standard. It is a separate specification,
implemented by every major Fortran compiler, that shares the work of a loop
between threads within one process. All the threads see the same memory, which
is what makes it easy to use and easy to get wrong.

An OpenMP program is an ordinary Fortran program with directives added. The
directives are written as comments beginning with ``!$omp``, so a compiler that
is not told to enable OpenMP treats them as comments and produces a working
serial program from the same source.

.. literalinclude:: ../../source/openmp/omp_sum.f90
   :language: Fortran
   :linenos:

Two OpenMP features appear in this example.

The ``!$omp parallel do`` directive splits the iterations of the following loop
between the available threads. The ``reduction(+:total)`` clause says that
``total`` is an accumulator: each thread gets a private copy initialised to
zero, and the copies are added together when the loop finishes. Without the
clause every thread would write to the same variable and the result would
depend on timing — the classic data race.

Lines beginning with ``!$`` rather than ``!$omp`` are conditional compilation.
When OpenMP is enabled the two characters are replaced by spaces and the line
becomes a statement; otherwise it stays a comment. This is how ``use omp_lib``
and the call to ``omp_get_max_threads`` can appear in a program that must also
compile without OpenMP.

Compiling and running
---------------------

Without the OpenMP switch the directives are comments and the program runs on
one thread::

   $ gfortran omp_sum.f90 -o omp_sum
   $ ./omp_sum
    sum       =   1.6449339668472596
    pi**2 / 6 =   1.6449340668482264

With ``-fopenmp`` the same source becomes a threaded program::

   $ gfortran -fopenmp omp_sum.f90 -o omp_sum
   $ ./omp_sum
    threads available :          12
    sum       =   1.6449339668482732
    pi**2 / 6 =   1.6449340668482264

The switch is ``-fopenmp`` for gfortran, ``-qopenmp`` for the Intel compilers
and ``-mp`` for ``nvfortran``. The number of threads is taken from the
environment variable ``OMP_NUM_THREADS`` if it is set::

   $ OMP_NUM_THREADS=4 ./omp_sum

Note that the two sums differ in the last few digits. Nothing is wrong: adding
the same floating point numbers in a different order gives a slightly different
answer, and a reduction adds them in whatever order the threads finish. A
parallel program that must give bit-identical results run after run needs more
care than this example takes.

Common directives
-----------------

.. list-table::
    :header-rows: 1
    :widths: 35 65

    * - Directive or clause
      - Description
    * - ``!$omp parallel do``
      - Splits the iterations of the following loop between threads.
    * - ``!$omp parallel``
      - Opens a region that every thread executes.
    * - ``!$omp critical``
      - Only one thread at a time may execute the enclosed block.
    * - ``private(a, b)``
      - Each thread gets its own uninitialised copy of the listed variables.
    * - ``shared(a, b)``
      - The listed variables are the same storage for every thread.
    * - ``reduction(op:var)``
      - Combines per-thread copies of ``var`` with ``op``, which can be
        ``+``, ``*``, ``max``, ``min``, ``.and.`` and others.
    * - ``default(none)``
      - Requires every variable in the region to be listed as private or
        shared. Worth using for the same reason as **implicit none**.

The loop control variable of a parallelised loop is private automatically. Any
other variable that is written inside the loop almost certainly needs to be
declared private or handled with a reduction.

Coarrays
========

Coarrays are Fortran's own parallel model, and unlike OpenMP they are part of
the language — they were added in Fortran 2008 and extended in Fortran 2018.

The model is different from OpenMP. Rather than one program growing extra
threads, the program is started as several independent copies, called
**images**, each with its own variables. The images run the same code from the
first statement to the last. What makes them a parallel program rather than
several unrelated ones is that a variable declared as a coarray can be read and
written across images.

A coarray is declared by adding codimensions in square brackets:

.. code-block:: Fortran

    real :: partial[*]              ! one scalar on every image
    real :: field(100)[*]           ! an array of 100 on every image
    integer :: counters[2,*]        ! images arranged in a 2D grid

The ``*`` means that the number of images is decided when the program is run,
not when it is compiled. Referring to ``partial`` means this image's copy;
``partial[3]`` means the copy belonging to image 3.

.. literalinclude:: ../../source/coarrays/coarray_sum.f90
   :language: Fortran
   :linenos:

``this_image()`` returns the number of the running image, counted from 1, and
``num_images()`` returns how many there are. Together they are enough to divide
work: each image here sums every ``num_images()``-th number, so with four
images image 1 takes 1, 5, 9, ... and image 2 takes 2, 6, 10, ...

**sync all** is a barrier. Every image waits there until all the others have
arrived. Without it, image 1 could read ``partial[2]`` before image 2 had
finished computing it. Synchronisation is the part of a coarray program that
needs the most care: too little gives wrong answers that appear only sometimes,
and too much gives a correct program that is no faster than the serial one.

The second half of the example does the same reduction with **co_sum**, one of
the collective subroutines added in Fortran 2018. Collectives are both shorter
and easier to get right than hand-written coindexing, and they let the runtime
use a tree reduction rather than a loop over images. The others are
**co_max**, **co_min**, **co_broadcast** and **co_reduce**.

Compiling and running
---------------------

gfortran disables coarrays unless it is told which coarray runtime to use::

   $ gfortran -fcoarray=single coarray_sum.f90 -o coarray_sum
   $ ./coarray_sum
    images        :           1
    sum by hand   :   5050.0000000000000
    sum by co_sum :   5050.0000000000000

``-fcoarray=single`` compiles the coarray syntax but runs the program as a
single image. It is the right choice while a program is being written, since it
checks the code without needing anything installed.

For more than one image, gfortran needs the OpenCoarrays library, which
provides an MPI-based runtime::

   $ gfortran -fcoarray=lib coarray_sum.f90 -o coarray_sum -lcaf_mpi
   $ cafrun -n 4 ./coarray_sum

The Intel compilers have coarray support built in and use ``-coarray`` instead.

Choosing between them
=====================

.. list-table::
    :header-rows: 1
    :widths: 20 40 40

    * - Model
      - Good for
      - Watch out for
    * - **do concurrent**
      - Loops whose iterations are independent. Costs nothing, documents an
        assumption, and standard.
      - Most compilers still generate serial code for it. It cannot express a
        reduction.
    * - **OpenMP**
      - Getting an existing serial program to use the cores of one machine,
        a loop at a time.
      - Not part of the language. Everything is shared by default, so a
        forgotten ``private`` is a silent data race.
    * - **Coarrays**
      - Programs designed to be parallel from the start, and for scaling
        beyond one machine.
      - Requires a coarray runtime for more than one image. Synchronisation
        errors are hard to reproduce.

The three are not exclusive. A common arrangement in scientific codes is
coarrays or MPI between machines and OpenMP inside each one.

A more complete treatment of all three can be found in Metcalf and Reid
[metcalfreid18]_.
