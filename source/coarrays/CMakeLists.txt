add_executable(coarray_sum coarray_sum.f90)

# Coarrays are off by default in gfortran; a single image is enough to
# compile and run the example.

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    target_compile_options(coarray_sum PRIVATE -fcoarray=single)
endif()
