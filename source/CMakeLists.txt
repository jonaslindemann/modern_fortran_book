cmake_minimum_required(VERSION 3.20)
project(modern_fortran_book LANGUAGES Fortran)

option(USE_LAPACK "Build the LAPACK examples (requires BLAS and LAPACK)" OFF)
option(USE_F2PY "Build the f2py example (requires Python with numpy)" OFF)
option(USE_SUBMODULES "Build the submodules example" ON)

# Submodules arrived in gfortran 6.

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU" AND CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 6)
    message(STATUS "gfortran < 6, disabling submodules example.")
    set(USE_SUBMODULES OFF)
endif()

# Collect all example programs in bin/debug or bin/release.

get_property(MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

if(NOT MULTI_CONFIG AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/$<LOWER_CASE:$<CONFIG>>)

enable_testing()

# Shared modules (mf_datatypes, mf_utils) used by many of the examples.

add_subdirectory(mf_lib)

set(EXAMPLES
    getting_started variables expressions logic loops case
    arr_slices arr_expressions array_features zero_size strings formatting
    functions subroutines optional_arguments procedures_as_arguments pure_elemental
    allocatable_dummy allocatable_function move_alloc dynamic_fcodes pointers
    modules private_entities overloading operator_overloading submodules
    oo_programming polymorphism
    unformatted_io namelist_io error_handling error_stop iso_env
    do_concurrent openmp coarrays
    c_interop c_calls_fortran fortran_calls_c
    sample1 sample2 fea_code lapack testing
)

if(USE_F2PY)
    list(APPEND EXAMPLES f2py)
endif()

foreach(example IN LISTS EXAMPLES)
    add_subdirectory(${example})
endforeach()
