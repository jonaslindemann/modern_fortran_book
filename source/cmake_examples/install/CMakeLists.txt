cmake_minimum_required(VERSION 3.20)
project(multiple_install LANGUAGES Fortran)

add_executable(multiple_install myprog.f90 mymodule.f90)

install(TARGETS multiple_install RUNTIME DESTINATION bin)
