# Modern Fortran in Science and Technology

This book is an introduction in programming with Fortran 95/2003/2008 in science and technology. The book also covers methods for integrating Fortran code with other programming languages both dynamic (Python) and compiled languages (C++). An introduction in using modern development enrvironments such as QtCreator/Eclipse/Photran, for debugging and development is also given.

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
