add_library(mf_lib STATIC mf_datatypes.f90 mf_utils.f90)

# Keep the .mod files in their own directory so that examples linking
# mf_lib find them without clashing with their own modules.

set_target_properties(mf_lib PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules)
target_include_directories(mf_lib PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/modules)
