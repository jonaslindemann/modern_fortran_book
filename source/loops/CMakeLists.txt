add_executable(loop1 loop1.f90)
add_executable(loop2 loop2.f90)
target_link_libraries(loop2 PRIVATE mf_lib)
add_executable(loop3 loop3.f90)
