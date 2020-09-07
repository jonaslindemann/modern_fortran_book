**********************
Appendix 1 - Exercises
**********************

Variables and data types
========================

**1-1** Which of the following names can be used as Fortran variable names?

  a) number_of_stars
  b) fortran_is_a_nice_language_to_use
  c) 2001_a_space_odyssey
  d) more$_money

**1-2** Declare the following variables in Fortran: 2 scalar integers a, and b, 3 floating point scalars c, d and e, 2 character strings infile and outfile and a logical variable f.

**1-3** Declare a floating point variable *a* that can represent values between 10\ :math:`^{-150}` and 10\ :math:`^{150}` with 14 significatn numbers. 

**1-4** What is printed by the following program?

.. code-block:: Fortran

    program precision

        implicit none

        integer, parameter :: ap = &
        selected_real_kind(15,300)

        real(ap) :: a, b

        a = 1.234567890123456
        b = 1.234567890123456_ap

        if (a==b) then
            write(*,*) 'Values are equal.'
        else
            write(*,*) 'Values are different.'
        endif

        stop

    end program precision

Arrays and matrices
===================

**2-1** Declare a :math:`[3 \times 3]` floating point array, :math:`\mathbf{Ke}`, and an 3 element integer array, :math:`\mathbf{f}`.

**2-2** Declare an integer array, :math:`\mathbf{idx}`, with the indices [0, 1, 2, 3, 4, 5, 6, 7]

**2-3** Give the following assignments:

a) Floating point array, **A**, is assigned the value 5.0 at (2,3).
b) Integer matrix, **C**, is assigned the value 0 at row 2.

**2-4** Write a program declaring a floating point matrix, **I**, with the
dimensions [10×10] and initialise it with the identity matrix.

**2-5** Declare an allocatable 2-dimensional floating point array and a 1-dimensional floating point vector. Also show programstatements how memory for these variables are allocated and deallocated.

**2-6** Create a subroutine, **identity**, initialising a *arbitrary* twodimensionl to the identity matrix. Write a program illustrating the use of the subroutine.

**2-7** Create a program that:

a) Defines an array to have 100 elements;
b) assigns to the elements the values 1,2,3, ..., 100;
c) reads two integer values in the range 1 to 100;
d) reverses the order of the elements of the array in the range specified by the two values.

**2-8** Given the array declaration

.. code-block:: Fortran
    
    real, dimension(50,20) :: a

write array sections representing

i) the first row of a;
ii) the last column of a;
iii) every second element in each row and column;
iv) as for (iii) in reverse order in both dimensions;

**2-9** Complete excercise F.2 using array syntax instead of do constructs.

**2-10** Create a derived data type for a particle in a particle system. The particle should have the following attributes:

* position
* velocity
* mass

Create an allocatable array with 1000 particles. Initialise all particles with the position (0,0,0) and a random velocity and a mass of 1.0.   

Conditional statements
======================

**3-1** Give the following if-statements:

a) If the value of the variable, **i**, is greater than 100 print ’i is greater than 100!’
b) If the value of the logical variable, **extra_filling**, is true print ’Extra filling is ordered.’, otherwise print ’No extra filling.’.

**3-2** Give a case-statment for the variable, **a**, printing ’a is 1’ when a is 1, ’a is between 1 and 20’ for values between 1 and 20 and prints ’a is not between 1 and 20’ for all other values.

Repetitive statements
=====================

**4-1** Write a program consisting of a do-statement 1 to 20 with the control variable, i. For values, i, between 1 till 5, the value of i is printed, otherwise ’i>5’ is printed. The loop is to be terminated when i equals 15.

Built-in functions
==================

**5-1** Give the following expressions in Fortran:

a) :math:`\frac{1}{\sqrt{2}}`
b) :math:`e^{x} \sin ^{2} x`
c) :math:`\sqrt{a^{2} +b^{2}}`
d) :math:`\left| x-y\right|`

**5-2** Give the following matrix and vector expressions in Fortran.
Also give appropriate array declarations:

a) :math:`\mathbf{AB}`
b) :math:`\mathbf{A^{T} A}`
c) :math:`\mathbf{ABC}`
d) :math:`\mathbf{a\cdot b}`

**5-3** Show expressions in Fortran calculating maximum, mininmum, sum and product of the elements of an array.

Program units and subroutines
=============================

**6-1** Implement a function returning the value of the the following
expression:

:math:`e^{x} \sin ^{2} x`

**6-2** Create a module, , containing the function in 1-21 and a function for converting a string to an integer value. Change the program in 1-21 to use this module. The module is placed in a separate file, and the main program in **main.f90**. 

**6-3** A subroutine receives as an argument an array of values, x, and the number of elements in x, n. If the mean and variance of the values in x are estimated by 

.. math::

    mean = \frac{1}{n}\sum_{i=1}^{n}x(i)

and

.. math::

    variance = \frac{1}{1-n}\sum_{i=1}^{n}(x(i)-mean)

Write a subroutine which returns these calculated values as arguments. The subroutine check for invalid values of n (<=1). Write a main program that illustrates the use of this subroutine.

Input and output
================

**7-1** Write a program which reads a value, x, and calculates and prints the corresponding value x/(1.+x). The case x=-1 shoud produce an error message and be followed by an attempt to read a new value of x.

**7-2** Write a program listing :math:`f(x)=\sin x` from :math:`-1.0` to :math:`1.0` inintervals of :math:`0.1`. The output from the program should have the following format:

::

             111111111122222222223
    123456789012345678901234567890
     x      f(x)                  
    -1.000 -0.841                  
    -0.900 -0.783                  
    -0.800 -0.717                  
    -0.700 -0.644                  
    -0.600 -0.565                  
    -0.500 -0.479                  
    -0.400 -0.389                  
    -0.300 -0.296                  
    -0.200 -0.199                  
    -0.100 -0.100                  
     0.000  0.000                  
     0.100  0.100                  
     0.200  0.199                  
     0.300  0.296                  
     0.400  0.389                  
     0.500  0.479                  
     0.600  0.565                  
     0.700  0.644                  
     0.800  0.717                  
     0.900  0.783                  
     1.000  0.841                  

**7-3** Write a program calculating the total length of a piecewise linear curve. The curve is defined in a textfile line.dat.

The file has the following structure:

::

    {number of points n in the file}
    {x-coordinate point 1} {y-coordinate point 1}
    {x-coordinate point 2} {y-coordinate point 2}
    .
    .
    {x-coordinate point n} {y-coordinate point n}

The program must not contain any limitations regarding the number of points in the number of points in the curve read from the file.

String manipulation
===================

**8-1** Declare 3 strings, **c1**, **c2** and **c3** containing the words ’Fortran’,
’is’ och ’fun’. Merge these into a new string, **c4**, making a
complete sentence.

**8-2** Write a function converting a string into a floating point value. Write a program  illustrating the use of the function.                         |

Object-oriented programming
===========================

**9-1** Implement a derived datatype for a vector and use operator overloading to implement common
vector operations such as adding, subtracting and multiplication (cross-product).



















