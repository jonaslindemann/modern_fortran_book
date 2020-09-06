Fortran and Python
==================

When developing numerical codes today, it is more and more important to
be able to combine benefits form many programming languages. One
language that have gained popularity in numerical computing i Python.
Python is a powerful dynamic scripting language, which is easy to use
and combined with the Scipy toolkit it can provide a environment very
similar to MATLAB. Python also supports the development of a multitude
of different kinds of applications ranging from graphical user
interfaces to web interfaces and web services.

By combining Fortran and Python, the performance of Fortran can be
combined with the easy of use and flexibility of Python. This chapter
describes a method for combining these languages using a special tool,
f2py.

Python extension modules
------------------------

In addition to implement Python modules in Python, modules can also be
implemented in C using a special API, which usually is found in the
libpython library. To illustrate how an extension module is developed, a
simple sum function will be implemented in an extension module,
calcualtions, using the Python extension API.

A typical Python extension module requires 3 parts:

-  Exported functions defined using the Python extension API.

-  Module function table declaring all exported functions in the module.

-  Module initialisation function for initialising the module and
   function table.

An exported function must be declared in a format that can be understood
by Python. Our exported sum function is declared as shown in the
following code:

.. code-block:: C

   static PyObject*
   sum(PyObject *self, PyObject *args)

The left side declares the return values from the function. This
declaration must always be there even if the function does not return
anything. Next, the sum function is declared. All exported functions
have the same arguments. is a pointer to the module instance that the
function belongs to. The second argument is a special Python object
containing the arguments that the function is called with.

Next, the input arguments must be parsed. This is done using the
-function in the Python API. This function parses the input arguments, ,
for the required parameters. If no match is found the function returns
NULL, which will trigger an exception in the Python interpreter. If a
match is found the function will assign values to provided C-variables.
Argument parsing for our sum function is shown in the following code:

.. code-block:: C

   // C variables that will contain input values

   double a;
   double b;

   // Parse input arguments

   if (!PyArg_ParseTuple(args, "dd", &a, &b))
       return NULL;

First, variables, and , are declared for storing the actual input
arguments. The -function takes the input parameter, args, and processes
this according to a signature string describing the required Python
arguments. Our function sum takes two double values as input arguments,
the signature string for this is ”dd”.

Now we have all input data, so now we do our actual computation in C:

.. code-block:: C

   double c = a + b;

To be able to use the computed value in Python it has to be converted to
a PyObject. This can be done using the function . This function is
similar to the -function as it also uses the signature string to define
what Python-datatypes to create. This is used in the last part of the
-function to return a Python-datatype.

.. code-block:: C

   return Py_BuildValue("d", c);

The complete sum function then becomes:

.. code-block:: C

   static PyObject*
   sum(PyObject *self, PyObject *args)
   {
       double a;
       double b;

       // Parse input arguments

       if (!PyArg_ParseTuple(args, "dd", &a, &b))
           return NULL;

       // Do our computation

       double c = a + b;

       // Return the results

       return Py_BuildValue("d", c);
   }

To be able to compile this function as an extension module, a function
table and module initialisation have to be added. The additional code
required is shown below:

.. code-block:: C

   // Module function table.

   static PyMethodDef
   module_functions[] = {
       { "sum", sum, METH_VARARGS, "Calculate sum." },
       { NULL }
   };

   // Module initialisation

   void
   initcext(void)
   {
       Py_InitModule3("cext", module_functions, "A minimal module.");
   }

To build the extension module, the module in NumPy is used. The
following is used to build the extension module:

.. code-block:: Python

   from numpy.distutils.core import setup, Extension

   setup(
       ext_modules = [
           Extension("cext",
               sources=["calculations_c.c"]),
       ]
   )

Building the module from the command line is then done using the
following command:

:: 

   > python setup.py build
   running build
   running build_ext
   building 'calculations' extension
   gcc -fno-strict-aliasing -I/Users/lindemann/anaconda/include -arch x86_64 -DNDEBUG -g -fwrapv -O3 -Wall -Wstrict-prototypes -I/Users/lindemann/anaconda/include/python2.7 -c calculations.c -o build/temp.macosx-10.5-x86_64-2.7/calculations.o
   gcc -bundle -undefined dynamic_lookup -L/Users/lindemann/anaconda/lib -arch x86_64 -arch x86_64 build/temp.macosx-10.5-x86_64-2.7/calculations.o -L/Users/lindemann/anaconda/lib -o build/lib.macosx-10.5-x86_64-2.7/calculations.so

The following example shows how the module can be used like any other
module in Python:

.. code-block:: Python

   >>> import cext
   >>> dir(cext)
   ['__doc__', '__file__', '__name__', '__package__', 'sum']
   >>> s = cext.sum(2.0, 3.0)
   >>> print s
   5.0
   >>>

Integrating Fortran in extension modules
----------------------------------------

To integrate Fortran in a Python extension module, requires us to
compile and link Fortran code into the extension module. To illustrate
this, the example in the previous section will be modified to call a
fortran subroutine to perform the computation. To link a Fortran routine
with a C, the calling convention in Fortran must be adapted to C. In the
following example the , and is used to define a Fortran routine that
uses the C calling convention and C datatypes to make the linking
easier:

.. code-block:: Fortran

   subroutine forsum(a, b, c) bind(C, name='forsum')

       use iso_c_binding

       real(c_double), value :: a, b
       real(c_double)        :: c

       c = a + b

   end subroutine forsum

The code in the Python extension module is now updated to call the
Fortran routine as shown below:

.. code-block:: C

   static PyObject*
   sum(PyObject *self, PyObject *args)
   {
       double a;
       double b;
       double c;

       // Parse input arguments

       if (!PyArg_ParseTuple(args, "dd", &a, &b))
           return NULL;

       // Do our computation

       forsum(a, b, &c);

       // Return the results

       return Py_BuildValue("d", c);
   }

The reason for the & operator is to pass the -variable as a reference to
the Fortran routine.

To build the modified extension module, the Fortran routine must be
compiled separately and then provided as a -file to the script:

.. code-block:: Python

   from numpy.distutils.core import setup, Extension

   setup(
       ext_modules = [
           Extension("fext",
               sources=["fext.c"],
               extra_objects=["forsum.o"])
       ]
   )

It is also possible to transfer matrices between Fortran and Python.
However, it requires even more complicated binding code. Instead of
doing this by hand, special tools can be used to automatically generate
the binding code for us as well as enabling us to use NumPy arrays to
transfer matrices between Fortran and Python in an efficient way.

F2PY
----

F2PY is a tool developed by Pearu Peterson that parses Fortran code,
generates Python wrapper code and compiles it as a Python extension
module. F2PY automatically create wrapper code for Fortran arrays, so
that NumPy arrays can be passed directly to the generated functions.

To illustrate the process of generating an extension module with F2PY
the following simple Fortran routine will be wrapped as a module:

.. code-block:: Fortran

   subroutine simple(a,b,c)

       real, intent(in) :: a, b
       real, intent(out) :: c

       c = a + b

   end subroutine simple

To be able to use F2PY effectively it is important that the -attribute
is used on the subroutine arguments. If not specified, F2PY, will treat
all subroutine parameters as input-variables and no output parameters
can be passed back to the the calling Python routine.

To create a Python module from the source code we execute the -command
on the command line as show below:

::

   > f2py -m fortmod -c simple.f90
   ...
   3n535b8krwsz88vl8bm0000gn/T/tmp5STblc/src.macosx-10.5-x86_64-2.7/fortranobject.o /var/folders/w6/1zqjp3n535b8krwsz88vl8bm0000gn/T/tmp5STblc/simple.o -L/opt/local/lib/gcc49/gcc/x86_64-apple-darwin14/4.9.1 -L/Users/lindemann/anaconda/lib -lgfortran -o ./fortmod.so
   Removing build directory /var/folders/w6/1zq...

In the build directory there should now be a or a depending on the
platform used.

The new module is loaded and used as shown in the following example:

.. code-block:: Python

   >>> import fortmod
   >>> print fortmod.simple(2.0, 3.0)
   5.0

F2PY will automatically generate built-in documentation in the module.
To display this documentation the property is used, as shown in the
following example:

::

   >>> print fortmod.__doc__
   This module 'fortmod' is auto-generated with f2py (version:2).
   Functions:
     c = simple(a,b)
   .
   >>> print fortmod.simple.__doc__
   c = simple(a,b)

   Wrapper for ``simple``.

   Parameters
   ----------
   a : input float
   b : input float

   Returns
   -------
   c : float

As show above, F2PY generates documentation both for the generated
module as well as for the individual functions.

Already now it is clear that using F2PY is significantly easier that
hand-coding Python wrappers for Fortran. F2PY takes care of all the
steps.

Passing arrays
~~~~~~~~~~~~~~

F2PY will automatically handle conversion of NumPy arrays when calling a
Fortran extension module. However, it is important to note that NumPy by
default uses C ordered arrays. These will be automatically converted to
Fortran ordered arrays. For smaller arrays the overhead is not so large,
but for large arrays the overhead can be significant. To avoid the
automatic conversion, NumPy arrays should be created with the option in
the array constructor, as shown in the following example:

.. code-block:: Python

   A = ones((10,10), 'f', order='F')

Using this option will pass the allocated memory for the NumPy array
directly to the Fortran routine without conversion.

A more complete example - Matrix multiplication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To illustrate the use of arrays in a Fortran extension module we create
a Fortran subroutine that takes two input arrays and returns the matrix
multiplication of these two arrays, The first version of the function is
shown below:

.. code-block:: Fortran

   ! A[r,s] * B[s,t] = C[r,t]
   subroutine matrix_multiply(A,r,s,B,t,C)
       integer :: r, s, t
       real, intent(in) :: A(r,s)
       real, intent(in) :: B(s,t)
       real, intent(out) :: C(r,t)

       C = matmul(A,B)
   end subroutine matrix_multiply

Input variables define the sizes of the incoming matrices. We use the
Fortran attributes and to tell F2PY what should be treated as an input
variable or an output variable. Creating a Fortran extension module with
F2PY on the above routine produces the following corresponding Python
routine (from the generated documentation):

::

   c = matrix_multiply(a,b,[r,s,t])

   Wrapper for ``matrix_multiply``.

   Parameters
   ----------
   a : input rank-2 array('f') with bounds (r,s)
   b : input rank-2 array('f') with bounds (s,t)

   Other Parameters
   ----------------
   r : input int, optional
       Default: shape(a,0)
   s : input int, optional
       Default: shape(a,1)
   t : input int, optional
       Default: shape(b,1)

   Returns
   -------
   c : rank-2 array('f') with bounds (r,t)

We can see in the documentation that the syntax of the Python routine
is:

::

   c = matrix_multiply(a,b,[r,s,t])

The Fortran output argument, is returned on the left side and the input
arguments, are input parameters to the Fortran routine. Please note that
the size input parameters will be provided by the generated function and
are not required when calling the routine from Python.

The created extension module can be uses from Python as shown in the
following code:

.. code-block:: Python

   from numpy import *
   from fortmod import *

   A = ones((6,6), 'f', order='F') * 10.0
   B = ones((6,6), 'f', order='F') * 20.0

   C = matrix_multiply(A, B)

   print C

Output from the Python code is:

:: 

   [[ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]]

Output variables, , from Fortran will be automatically created. It is
not possible to reference data in an already existing array as shown in
the following example:

.. code-block:: Python

   A = ones((6,6), 'f', order='F') * 10.0
   B = ones((6,6), 'f', order='F') * 20.0
   C = zeros((6,6), 'f', order='F')

   print "id of C before multiply =",id(C)

   C = matrix_multiply(A, B)

   print "id of C after multiply =",id(C)

In this example, an array is created before the call to our Fortran
routine. The id or memory location is queried using the and displayed
before and after the call. The output is:

::

   id of C before multiply = 4299985824
   id of C after multiply = 4340070160

The array is apparently overwritten. This is due to how the Python
language is designed. An euqality operator will replace the reference to
the first instance with a new instance. The next section covers how to
pass variables that can be modified by Fortran.

Matrix mulitplication with modifiable output variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the Fortran extension module should be able to modify the contents of
the incoming arrays, the attribute must be used. This tells F2PY to
generate code that handles this. Our modified matrix multiplication
subroutine then becomes:

.. code-block:: Fortran

   ! A[r,s] * B[s,t] = C[r,t]
   subroutine matrix_multiply2(A,r,s,B,t,C)
       integer :: r, s, t
       real, intent(in) :: A(r,s)
       real, intent(in) :: B(s,t)
       real, intent(inout) :: C(r,t)

       C = matmul(A,B)
   end subroutine matrix_multiply2

The only difference is the attribute on the array declaration. However,
the generated Python routine is quite different:

::

   matrix_multiply2(a,b,c,[r,s,t])

   Wrapper for ``matrix_multiply2``.

   Parameters
   ----------
   a : input rank-2 array('f') with bounds (r,s)
   b : input rank-2 array('f') with bounds (s,t)
   c : in/output rank-2 array('f') with bounds (r,t)

   Other Parameters
   ----------------
   r : input int, optional
       Default: shape(a,0)
   s : input int, optional
       Default: shape(a,1)
   t : input int, optional
       Default: shape(b,1)

Now all input parameters are given on the right side. Now it is possible
to directly modify the variable in the Fortran code and pass any changes
back to Python, without copying the data. The memory address of the
array is the same as used by the NumPy array in the Python code. The
following code shows how to use the modified Fortran extension:

.. code-block:: Python

   A = ones((6,6), 'f', order='F') * 10.0
   B = ones((6,6), 'f', order='F') * 20.0
   C = zeros((6,6), 'f', order='F')

   print "id of C before multiply =",id(C)

   matrix_multiply2(A, B, C)

   print "id of C after multiply =",id(C)

   print C

For this code to work it is now required to create the array, , before
calling the Fortran extension. This is due to the fact that the memory
area for the array needs to exist before the call as the pointer to the
array is passed directly to the Fortran code. The output of the Python
code is shown below:

::

   id of C before multiply = 4302082976
   id of C after multiply = 4302082976
   [[ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]
    [ 1200.  1200.  1200.  1200.  1200.  1200.]]

From the output, we can see that the memory of the array is the same
before and after the call to the Fortran extension module.
