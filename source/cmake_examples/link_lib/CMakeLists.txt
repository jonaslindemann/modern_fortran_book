cmake_minimum_required(VERSION 2.6)
project(multiple)
enable_language(Fortran)

add_executable(multiple myprog.f90 mymodule.f90)
target_link_libraries(multiple blas m)