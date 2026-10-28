****************************
Mixed language programming
****************************

Few scientific programs are written in a single language today. A solver may be
written in Fortran, driven by a Python script, plot its results with a Python
library and call a C library for reading files. Each language is used for what
it is good at: Fortran for fast numerical kernels, Python for gluing things
together, exploring data and building user interfaces, and C because almost
every library and operating system interface is available from it.

Mixing languages used to be a matter of guessing what the compiler did with the
names and arguments of a routine, and that guess was different for every
compiler. Fortran 2003 changed this by making interoperability with C part of
the language standard. C has become the common ground: a Fortran routine that
can be called from C can also be called from C++, Python, Julia, R and MATLAB,
since all of them can call C.

This chapter first describes how Fortran and C call each other, and then three
ways of calling Fortran from Python: **ctypes**, **F2PY** and building a
complete Python package with **meson-python**.

.. _c-interop:

Interoperability with C
=======================

The iso_c_binding module
------------------------

The intrinsic module **iso_c_binding** defines the kind parameters that make a
Fortran variable identical to the corresponding C type. The most commonly used
are:

.. list-table::
   :header-rows: 1
   :widths: 40 30

   * - Fortran
     - C
   * - ``integer(c_int)``
     - ``int``
   * - ``integer(c_long)``
     - ``long``
   * - ``integer(c_int64_t)``
     - ``int64_t``
   * - ``integer(c_size_t)``
     - ``size_t``
   * - ``real(c_float)``
     - ``float``
   * - ``real(c_double)``
     - ``double``
   * - ``complex(c_double_complex)``
     - ``double _Complex``
   * - ``logical(c_bool)``
     - ``_Bool`` / ``bool``
   * - ``character(kind=c_char)``
     - ``char``
   * - ``type(c_ptr)``
     - ``void *``
   * - ``type(c_funptr)``
     - pointer to a function

The module also defines constants such as **c_null_char** and **c_null_ptr**,
and the procedures **c_loc**, **c_f_pointer**, **c_associated** and
**c_sizeof** for working with C pointers.

A short program using the kinds is shown below:

.. literalinclude:: ../../source/c_interop/main.f90
   :language: Fortran
   :linenos:

Note that it is the kind that matters, not where the variable is used. A
``real(c_double)`` is an ordinary Fortran real and can be used in any
expression. On all common platforms it is also the same kind as ``real64`` from
**iso_fortran_env**, but only ``c_double`` is guaranteed to match C.

The bind(C) attribute
---------------------

A Fortran compiler does not use the name of a procedure as the name the linker
sees. gfortran, for example, turns the subroutine ``forsum`` into ``forsum_``,
and a procedure ``mean`` in a module ``stats`` into ``__stats_MOD_mean``. Other
compilers use other schemes. Adding the **bind(C)** attribute to a procedure
tells the compiler to use the C calling convention and to give the procedure a
name a C compiler would recognise:

.. code-block:: Fortran

    function mean(x, n) result(m) bind(C, name='stats_mean')

The ``name`` is the name the procedure gets in C, and is case sensitive. If it
is left out, the Fortran name in lower case is used. Giving it explicitly is
good practice, especially for module procedures, as it lets the C name carry a
prefix that the Fortran name does not need.

The arguments of a **bind(C)** procedure must be interoperable, which in
practice means:

- scalars of the kinds from **iso_c_binding**. Fortran passes arguments by
  reference, so a scalar becomes a pointer in C, unless it is given the
  **value** attribute, in which case it is passed by value just as in C.
- arrays of explicit shape, ``x(n)``, or assumed size, ``x(*)``. C sees a
  pointer to the first element, so the size has to be passed as a separate
  argument.
- derived types declared with **bind(C)**, which correspond to C structs.
- **type(c_ptr)** and **type(c_funptr)** for pointers that Fortran does not
  need to look into.

Calling Fortran from C
----------------------

The following module implements three routines that are meant to be called from
C: the mean of an array, scaling an array in place and summing the rows of a
matrix:

.. literalinclude:: ../../source/c_calls_fortran/stats.f90
   :language: Fortran
   :linenos:

Note how the arguments are declared. The size arguments have the **value**
attribute, so C can pass a plain ``int``. The arrays do not, so C passes a
pointer. The **intent** attributes are not visible to C, but they still help the
Fortran compiler and the reader, and they correspond to whether the C prototype
should use ``const``.

The C side needs prototypes for the routines. They are best put in a header
file that is written once, next to the Fortran module:

.. literalinclude:: ../../source/c_calls_fortran/stats.h
   :language: C
   :linenos:

The routines are then called as any other C function:

.. literalinclude:: ../../source/c_calls_fortran/main.c
   :language: C
   :linenos:

Each source file is compiled with its own compiler. The program is easiest to
link with **gfortran**, since it adds the Fortran runtime library
automatically:

::

    $ gfortran -c stats.f90
    $ gcc -c main.c
    $ gfortran main.o stats.o -o c_calls_fortran
    $ ./c_calls_fortran
    mean = 3
    scaled = 10 20 30 40 50
    row sums = 10 26 42

If the program must be linked with the C compiler, for example because it is a
part of a larger C or C++ build, ``-lgfortran`` has to be added to the link
command. With CMake, both languages are enabled in the project and the source
files are simply listed together. CMake works out which compiler to use for the
linking:

.. code-block:: cmake

    cmake_minimum_required(VERSION 3.16)
    project(c_calls_fortran LANGUAGES C Fortran)

    add_executable(c_calls_fortran main.c stats.f90)

Storage order
~~~~~~~~~~~~~

The ``row_sums`` routine shows the most common mistake when passing matrices
between Fortran and C. C stores a matrix row by row, Fortran column by column.
The C array ``a[3][4]``, with 3 rows and 4 columns, is in memory exactly the
same as the Fortran array ``a(4, 3)``. That is why ``row_sums`` declares the
array as ``a(cols, rows)``, and why summing a C row means summing along the
first Fortran dimension, ``sum(a, dim=1)``.

In other words, a matrix passed between the languages appears transposed. This
is usually handled in one of two ways: by swapping the dimensions in the
Fortran declaration, as here, or by agreeing that the C code stores matrices in
column order, which is what most numerical C libraries, such as LAPACK, expect.

The difference in where indices start, at 0 in C and at 1 in Fortran, does not
matter across the boundary, as only the memory is passed and each language
indexes it in its own way.

Calling C from Fortran
----------------------

Calling C from Fortran works the other way around. The C function is described
to Fortran with an **interface** block, in which each procedure has the
**bind(C)** attribute and interoperable arguments. The following C file defines
a struct and three functions:

.. literalinclude:: ../../source/fortran_calls_c/geometry.c
   :language: C
   :linenos:

The Fortran program describes the same struct as a derived type with the
**bind(C)** attribute, and declares the functions in an interface block:

.. literalinclude:: ../../source/fortran_calls_c/main.f90
   :language: Fortran
   :linenos:

Inside an interface block, names from the enclosing module are not visible, so
the **import** statement is used to bring in the kinds and the ``point`` type.

``distance`` takes its arguments by value, as the C function does, and the
derived type is declared with **value** for that reason. ``translate`` takes a
pointer to an array of structs, which in Fortran is an assumed-size array,
``p(*)``.

Strings need more care. C does not store the length of a string but ends it
with a null character, while a Fortran string has a length but no terminator. A
string is passed to C as an array of ``character(kind=c_char)`` and the null
character has to be added by the caller. The module therefore wraps the C
function in an ordinary Fortran subroutine, ``greet``, which trims the string
and appends **c_null_char** before calling C. The rest of the program never
sees that the routine is implemented in C.

The program is built and run as follows:

::

    $ gcc -c geometry.c
    $ gfortran main.f90 geometry.o -o fortran_calls_c
    $ ./fortran_calls_c
    distance =   5.00
    translated =   1.00 -1.00  4.00  3.00  7.00  7.00
    Hello, Fortran, from C!

What is not interoperable
-------------------------

Many of the features that make Fortran convenient have no counterpart in C and
cannot be used directly in a **bind(C)** interface:

- assumed-shape, allocatable and pointer arrays, since C would not know how to
  read the array descriptor that the compiler passes,
- derived types with allocatable or pointer components, or with type-bound
  procedures,
- character variables with a length other than 1,
- optional arguments, before Fortran 2018.

The usual solution is the one used for ``greet`` above: a thin layer of
**bind(C)** routines with simple arguments, which in turn call the ordinary
Fortran code. Data structures that C does not need to look into can be passed
as a **type(c_ptr)**, created with **c_loc** and turned back into a Fortran
pointer with **c_f_pointer**.

Fortran 2018 removed some of these restrictions. With the C header
``ISO_Fortran_binding.h`` a C function can receive an assumed-shape,
allocatable or pointer array as a ``CFI_cdesc_t`` descriptor, and read its
shape and strides. Recent versions of gfortran and the Intel ifx compiler
support it, but for code that should work with many compilers the plain
interface above is still the safest choice.

Calling Fortran from Python
===========================

Python is today the most widely used language for driving numerical
computations. Combined with NumPy, SciPy and Matplotlib it provides an
environment similar to MATLAB, and it is used for everything from small scripts
to large workflow systems. Fortran and Python complement each other well: the
heavy computations are done in compiled Fortran, and everything around them in
Python.

Python can not call Fortran directly. The standard Python interpreter is written
in C, and what it can load is a C library. There are several ways of providing
one:

- **ctypes**, a module in the Python standard library, loads an ordinary shared
  library and calls its functions. No extra code has to be compiled, but the
  Fortran routines must have **bind(C)** interfaces, and the argument types
  have to be declared in Python.
- **F2PY**, which is a part of NumPy, reads Fortran source code and generates a
  complete Python extension module, including conversion of NumPy arrays. It
  works on ordinary Fortran code without **bind(C)**.
- An extension module can also be written in C or C++, using the Python C API
  directly or a tool such as Cython, pybind11 or nanobind, with the C code in
  turn calling Fortran through **bind(C)**. This gives the most control, but is
  rarely worth the effort when the purpose is only to call Fortran.

For most Fortran code, F2PY is the simplest choice. ctypes is useful when a
shared library with a C interface exists anyway, for example because it is also
called from C.

ctypes
------

ctypes is shown here with a module of three **bind(C)** routines: a dot
product, the BLAS operation :math:`y = ax + y`, and a matrix multiplication:

.. literalinclude:: ../../source/ctypes_example/vecops.f90
   :language: Fortran
   :linenos:

The module is compiled into a shared library. The command differs slightly
between platforms:

::

    $ gfortran -O2 -shared -fPIC vecops.f90 -o libvecops.so       # Linux
    $ gfortran -O2 -shared vecops.f90 -o libvecops.dylib          # macOS
    > gfortran -O2 -shared -static vecops.f90 -o libvecops.dll    # Windows

The ``-static`` option on Windows is explained at the end of this section.

The Python side loads the library and declares the arguments and the return
type of each function. Without these declarations ctypes would guess, and a
wrong guess will crash the interpreter rather than raise an exception.
NumPy provides **numpy.ctypeslib**, which makes this easier: **load_library**
finds the library with the right file extension for the platform, and
**ndpointer** describes an argument that must be a NumPy array of a given type,
number of dimensions and storage order:

.. literalinclude:: ../../source/ctypes_example/vecops.py
   :language: Python
   :linenos:

The small Python functions ``dot``, ``axpy`` and ``mat_mul`` hide the size
arguments, so that the rest of the program can call them as any other Python
function. Running the script gives:

::

    $ python vecops.py
    dot = 32.0
    y = [ 6.  9. 12.]
    a @ b =
    [[ 3.  3.]
     [12. 12.]]

``axpy`` modifies ``y`` in place. ctypes passes a pointer to the memory of the
NumPy array, and nothing is copied.

The ``flags`` given to **ndpointer** are checked on every call. NumPy creates
arrays in C order by default, and passing one where the Fortran routine expects
a matrix in column order is caught before Fortran is called:

.. code-block:: Python

    >>> vecops.mat_mul(np.ones((2, 2)), np.ones((2, 2)))
    ctypes.ArgumentError: argument 1: TypeError: array must have flags ['F_CONTIGUOUS']

An array can be converted with **numpy.asfortranarray**, or created in Fortran
order from the start by giving ``order="F"`` to the NumPy function creating it.

.. note::

   Since Python 3.8, Windows does not search the ``PATH`` for the libraries a
   loaded DLL depends on. A library built with gfortran depends on the
   gfortran runtime, ``libgfortran-5.dll`` and a few others, and loading it
   fails with ``FileNotFoundError: Could not find module ... (or one of its
   dependencies)``. Linking the runtime into the library with ``-static``
   avoids the problem. An alternative is to tell Python where the runtime is
   with ``os.add_dll_directory()`` before the library is loaded.

F2PY
----

F2PY is a tool, originally developed by Pearu Peterson and now part of NumPy,
that reads Fortran code, generates the C code for a Python extension module and
compiles everything into a module that can be imported. It converts NumPy
arrays to Fortran arrays automatically, and generates documentation for the
wrapped routines.

Since Python 3.12, which removed the **distutils** module, F2PY uses the
**Meson** build system to compile the extension module. Meson and Ninja are
installed with pip together with NumPy, and a C compiler is needed in addition
to the Fortran compiler:

::

    $ python -m pip install numpy meson ninja

F2PY is run with ``python -m numpy.f2py``. The same tool is also installed as
the command ``f2py``, but using ``python -m`` guarantees that F2PY belongs to
the Python installation that will import the module.

A first example
~~~~~~~~~~~~~~~

The following subroutine will be wrapped as a Python module:

.. literalinclude:: ../../source/f2py/simple.f90
   :language: Fortran
   :linenos:

The module is built with the following command, where ``-m`` gives the name of
the Python module and ``-c`` tells F2PY to compile it:

::

    $ python -m numpy.f2py -c -m fortmod simple.f90

F2PY prints a lot of output while it builds the module. The result is a single
file in the current directory, named after the module, the Python version and
the platform, for example ``fortmod.cpython-312-x86_64-linux-gnu.so`` on Linux
or ``fortmod.cp312-win_amd64.pyd`` on Windows. It is imported as any other
module:

.. literalinclude:: ../../source/f2py/simple.py
   :language: Python
   :linenos:

F2PY has generated a docstring for the function, which is what the script
prints first:

::

    $ python simple.py
    c = simple(a,b)

    Wrapper for ``simple``.

    Parameters
    ----------
    a : input float
    b : input float

    Returns
    -------
    c : float

    c = 5.0

The Fortran subroutine has three arguments, but the Python function takes two
and returns the third. F2PY decides this from the **intent** attributes: an
``intent(in)`` argument becomes a parameter of the Python function, and an
``intent(out)`` argument becomes a return value. If there are several output
arguments, the function returns a tuple. Without **intent**, F2PY treats every
argument as input, and no results come back to Python. Using **intent** on all
arguments is therefore even more important here than in ordinary Fortran.

.. note::

   On Windows the module can fail to import with ``ImportError: DLL load
   failed``, for the same reason as described for ctypes above. Setting
   ``LDFLAGS`` before building links the gfortran runtime into the module:

   ::

       > $env:LDFLAGS = "-static"
       > python -m numpy.f2py -c -m fortmod simple.f90

Kind parameters
~~~~~~~~~~~~~~~

F2PY has to know the C type that each Fortran kind corresponds to. It
understands the kinds from **iso_c_binding**, such as ``c_double``, and
literal kinds, such as ``real(8)``, but not the named constants from
**iso_fortran_env**. A ``real(real64)`` argument is wrapped as a C ``float``,
and an ``integer(int64)`` as an ``int``. F2PY reports this only as a line
among its build output, and the module builds, imports and returns wrong
results. This is why the examples in this section use ``c_double``.

Code that uses ``real64`` can still be wrapped by telling F2PY what it means. A
file named ``.f2py_f2cmap`` in the directory where F2PY is run maps Fortran
kinds to C types:

.. code-block:: Python

    dict(real=dict(real64="double"), integer=dict(int32="int", int64="long_long"))

Fortran modules
~~~~~~~~~~~~~~~

Routines in Fortran modules are wrapped as well, and keep their module as a
namespace in Python. The following module contains two versions of a matrix
multiplication and a routine with an assumed-shape array argument:

.. literalinclude:: ../../source/f2py/matrix.f90
   :language: Fortran
   :linenos:

Several source files can be wrapped into the same Python module:

::

    $ python -m numpy.f2py -c -m fortmod simple.f90 matrix.f90

The documentation of the module lists what it contains:

.. code-block:: Python

    >>> import fortmod
    >>> print(fortmod.__doc__)
    This module 'fortmod' is auto-generated with f2py (version:2.5.4).
    Functions:
        c = simple(a,b)
    Fortran 90/95 modules:
      matrix --- matrix_multiply(),matrix_multiply_inplace(),frobenius_norm().

The routines in the module are reached as ``fortmod.matrix.matrix_multiply``,
and so on.

Passing arrays
~~~~~~~~~~~~~~

The docstring of ``matrix_multiply`` shows how F2PY has wrapped the array
arguments:

::

    c = matrix_multiply(a,b,[r,s,t])

    Wrapper for ``matrix_multiply``.

    Parameters
    ----------
    a : input rank-2 array('d') with bounds (r,s)
    b : input rank-2 array('d') with bounds (s,t)

    Other Parameters
    ----------------
    r : input int, optional
        Default: shape(a, 0)
    s : input int, optional
        Default: shape(a, 1)
    t : input int, optional
        Default: shape(b, 1)

    Returns
    -------
    c : rank-2 array('d') with bounds (r,t)

F2PY has seen that ``r``, ``s`` and ``t`` are the dimensions of the arrays, and
made them optional arguments that are taken from the shapes of the arrays
passed in. The output array ``C`` is allocated by the wrapper and returned. The
``'d'`` means a double precision array, which is the default type of a NumPy
array, ``float64``. The routine is used as follows:

.. literalinclude:: ../../source/f2py/matrix_out.py
   :language: Python
   :linenos:

::

    $ python matrix_out.py
    id of C before multiply = 2039738443280
    id of C after multiply  = 2039738443568
    [[1200. 1200. 1200. 1200. 1200. 1200.]
     [1200. 1200. 1200. 1200. 1200. 1200.]
     [1200. 1200. 1200. 1200. 1200. 1200.]
     [1200. 1200. 1200. 1200. 1200. 1200.]
     [1200. 1200. 1200. 1200. 1200. 1200.]
     [1200. 1200. 1200. 1200. 1200. 1200.]]

The **id** function returns the identity of a Python object, and it is
different before and after the call. The array ``C`` created before the call
is not used by Fortran at all. The assignment replaces it with the new array
returned by the wrapper.

Input arrays are converted automatically. If an array passed as ``intent(in)``
is in C order, or is of another type than the Fortran routine expects, F2PY
makes a converted copy before calling Fortran. This is convenient, but for
large arrays the copy can take longer than the computation. Arrays that are
passed to Fortran many times should therefore be created in Fortran order, of
the right type, from the start, as in the example above.

Arrays modified in place
~~~~~~~~~~~~~~~~~~~~~~~~

If Fortran should write its result into an existing array, the argument is
declared ``intent(inout)``, as in ``matrix_multiply_inplace``. The generated
Python function then takes the array as an argument and returns nothing:

::

    matrix_multiply_inplace(a,b,c,[r,s,t])

    ...
    c : in/output rank-2 array('d') with bounds (r,t)

.. literalinclude:: ../../source/f2py/matrix_inplace.py
   :language: Python
   :linenos:

::

    $ python matrix_inplace.py
    id of C before multiply = 2056056579600
    id of C after multiply  = 2056056579600
    [[1200. 1200. 1200. 1200. 1200. 1200.]
     ...

The array is the same object before and after the call, and Fortran has written
directly into its memory.

This only works if no conversion is needed, since a converted copy would be
modified instead of the original. F2PY therefore refuses arrays of the wrong
order or type for ``intent(inout)`` arguments, instead of silently copying:

.. code-block:: Python

    >>> fortmod.matrix.matrix_multiply_inplace(A, B, np.zeros((6, 6)))
    ValueError: failed to initialize intent(inout) array -- input not fortran contiguous
    >>> fortmod.matrix.matrix_multiply_inplace(A, B, np.zeros((6, 6), dtype=np.float32, order="F"))
    ValueError: failed to initialize intent(inout) array -- expected elsize=8 but got 4

Assumed-shape arrays
~~~~~~~~~~~~~~~~~~~~

The third routine in the module, ``frobenius_norm``, uses an assumed-shape
array, ``A(:, :)``, and has no size arguments. Such an array cannot be passed
from C, but F2PY handles it by generating a small Fortran wrapper with
explicit-shape arguments, which then calls the routine. From Python it looks
like any other function:

.. code-block:: Python

    >>> fortmod.matrix.frobenius_norm(np.ones((3, 3)))
    3.0

This means that modern Fortran code can usually be wrapped as it is, without
being rewritten in an older style for F2PY's sake.

Controlling the wrapping
~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes the defaults chosen by F2PY are not the desired ones, for example
when an argument should be hidden from Python, or when the Fortran code cannot
be changed to add **intent** attributes. F2PY reads special comments, starting
with ``!f2py``, which are ignored by the Fortran compiler:

.. code-block:: Fortran

    subroutine fill(x, n)
        integer :: n
        real(c_double) :: x(n)
        !f2py intent(out) x
        !f2py intent(in) n
        ...

For larger libraries, F2PY can also write a *signature file*, a ``.pyf`` file
describing the interfaces it has found, which can be edited and then used to
build the module. See the F2PY section of the NumPy documentation for details.

Building a Python package
-------------------------

Running F2PY by hand is fine while developing, but a module that others should
use is better distributed as a Python package that is installed with pip.
Packages that contain compiled code are today built with **meson-python**, a
build backend that lets Meson compile the code when the package is installed.
This replaces the ``setup.py`` files and **numpy.distutils**, which were used
for the same purpose earlier and do not work with current versions of Python
and NumPy.

A minimal package consists of the Fortran source, a ``pyproject.toml`` and a
``meson.build`` file:

::

    f2py_package/
    ├── pyproject.toml
    ├── meson.build
    └── src/
        └── fmatrix.f90

The Fortran module contains two routines:

.. literalinclude:: ../../source/f2py_package/src/fmatrix.f90
   :language: Fortran
   :linenos:

``pyproject.toml`` describes the package and tells pip to build it with
meson-python:

.. literalinclude:: ../../source/f2py_package/pyproject.toml
   :language: toml

``meson.build`` describes the build. It first asks NumPy where its header files
and the F2PY support code are, then runs F2PY to generate the C code for the
module, and finally compiles the generated files together with the Fortran
source into an extension module:

.. literalinclude:: ../../source/f2py_package/meson.build
   :language: text

The ``--lower`` option makes F2PY use lower case names in Python, whatever case
is used in the Fortran code. F2PY generates ``fmatrix-f2pywrappers2.f90`` for
code in Fortran modules. For code outside modules it is named
``fmatrix-f2pywrappers.f`` instead, and the ``output`` list has to be changed
accordingly. On Windows, the gfortran runtime is linked statically for the
reasons described earlier.

The package is built and installed with pip, from the directory containing
``pyproject.toml``:

::

    $ python -m pip install .
    ...
    Successfully installed fmatrix-0.1.0

After that, the module can be imported from any directory:

.. code-block:: Python

    >>> import numpy as np
    >>> import fmatrix
    >>> A = np.asfortranarray(np.arange(1.0, 7.0).reshape(2, 3))
    >>> fmatrix.fmatrix.frobenius_norm(A)
    9.539392014169456
    >>> fmatrix.fmatrix.scale(A, 2.0)
    >>> A
    array([[ 2.,  4.,  6.],
           [ 8., 10., 12.]])

``python -m build`` builds a *wheel*, a file that can be installed on other
machines without a compiler. Wheels are specific to a platform and a Python
version, and tools such as **cibuildwheel** are used to build the full set of
them, for example when publishing a package on PyPI.

Choosing an approach
====================

- To call Fortran from C or C++, or from any language that can call C, write
  **bind(C)** interfaces using the kinds from **iso_c_binding**, and keep them
  as a thin layer on top of the ordinary Fortran code.
- To call existing Fortran code from Python, use **F2PY**. It works on ordinary
  Fortran with **intent** attributes, including modules and assumed-shape
  arrays, and handles the NumPy arrays.
- When a shared library with **bind(C)** interfaces already exists, **ctypes**
  can call it without compiling anything more.
- When the Python module should be used by others, build it as a package with
  **meson-python**.

Whichever approach is used, the same two things cause most of the problems:
the types of the arguments must match exactly, and matrices must be stored in
the order the receiving language expects.
