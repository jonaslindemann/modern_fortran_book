add_executable(modules module_main.f90 module_truss.f90)
target_link_libraries(modules PRIVATE mf_lib)
