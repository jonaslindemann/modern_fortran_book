add_executable(fea_code module_main.f90 module_truss.f90)
target_link_libraries(fea_code PRIVATE mf_lib)
