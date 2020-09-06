if (USE_LAPACK)
find_package( BLAS REQUIRED )
find_package( LAPACK REQUIRED )

add_executable(lapack1 main.f90 datatypes.f90 utils.f90)
add_executable(lapack2 main2.f90 linalg.f90 datatypes.f90 utils.f90)
target_link_libraries(lapack1 ${LAPACK_LIBRARIES} )
target_link_libraries(lapack2 ${LAPACK_LIBRARIES} )
endif()
