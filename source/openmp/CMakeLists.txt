add_executable(omp_sum omp_sum.f90)

# The example only uses OpenMP through directives and !$ sentinels, so it
# still builds (and runs serially) when no OpenMP support is found.

find_package(OpenMP COMPONENTS Fortran)

if(OpenMP_Fortran_FOUND)
    target_link_libraries(omp_sum PRIVATE OpenMP::OpenMP_Fortran)
else()
    message(STATUS "OpenMP not found, omp_sum will run serially.")
endif()
