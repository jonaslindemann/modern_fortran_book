cmake_minimum_required(VERSION 2.6)
project(multiple_install)
enable_language(Fortran)

add_executable(multiple_install myprog.f90 mymodule.f90)

install(TARGETS multiple_install RUNTIME DESTINATION "bin")