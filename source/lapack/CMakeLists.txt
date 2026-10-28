if(USE_LAPACK)
    find_package(LAPACK REQUIRED)

    # datatypes and utils are shared by both programs; building them once
    # avoids two targets writing the same .mod files.

    add_library(lapack_utils STATIC datatypes.f90 utils.f90)

    add_executable(lapack1 main.f90)
    add_executable(lapack2 main2.f90 linalg.f90)
    target_link_libraries(lapack1 PRIVATE lapack_utils LAPACK::LAPACK)
    target_link_libraries(lapack2 PRIVATE lapack_utils LAPACK::LAPACK)
endif()
