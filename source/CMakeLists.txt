project(sciprog)
cmake_minimum_required(VERSION 3.10)
enable_language(Fortran)

set(USE_F2PY OFF)
set(USE_LAPACK OFF)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0.0")
    message("-- gfortran < 6 disabling submodules.")
    set(USE_SUBMODULES OFF)
  else()
    message("-- gfortran >= 6 enabling submodules.")
    set(USE_SUBMODULES ON)
  endif()
endif()

if(USE_F2PY)
    subdirs(arr_slices arr_expressions expressions variables loops unformatted_io error_handling array_features oo_programming
        allocatable_dummy allocatable_function dynamic_fcodes pointers overloading
        case formatting modules namelist_io operator_overloading optional_arguments
        private_entities procedures_as_arguments strings submodules
        subroutines sample1 sample2 zero_size logic functions fea_code lapack f2py )
else()
    subdirs(arr_slices arr_expressions expressions variables loops unformatted_io error_handling array_features oo_programming
        allocatable_dummy allocatable_function dynamic_fcodes pointers overloading
        case formatting modules namelist_io operator_overloading optional_arguments
        private_entities procedures_as_arguments strings submodules
        subroutines sample1 sample2 zero_size logic functions lapack fea_code)
endif()
