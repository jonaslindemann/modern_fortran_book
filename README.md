# Modern Fortran in Science and Technology

Authors: Jonas Lindemann and Ola Dahlblom

This book is an introduction to programming with Fortran 95/2003/2008/2018 in science and technology. It covers the language itself, from a first program to object-oriented programming, and parallel programming with do concurrent, OpenMP and coarrays. It also covers methods for calling Fortran from Python and for combining it with C, building larger projects with Make, CMake and fpm, and working in modern development environments such as Visual Studio Code and Qt Creator.

You can find the book in a more readable form at Read The Docs at the following link:

https://modern-fortran-in-science-and-technology.readthedocs.io/en/latest/

You can also find all the examples in the book in the **source** directory of this repo. All examples can be built using CMake as shown below:

    $ git clone https://github.com/jonaslindemann/modern_fortran_book.git
    $ cd modern_fortran_book/source
    $ mkdir build
    $ cd build
    $ cmake ..
    $ make
  
It will require a fortran compiler installed in the search path.
