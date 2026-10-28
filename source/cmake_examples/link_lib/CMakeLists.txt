cmake_minimum_required(VERSION 3.20)
project(multiple LANGUAGES Fortran)

add_executable(multiple myprog.f90 mymodule.f90)
target_link_libraries(multiple blas m)
