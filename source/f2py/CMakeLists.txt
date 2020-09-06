add_custom_target(
    fortmod ALL
    DEPENDS ${PROJECT_SOURCE_DIR}/f2py/simple.f90 ${PROJECT_SOURCE_DIR}/f2py/arr1.f90 ${PROJECT_SOURCE_DIR}/f2py/arr2.f90
    COMMAND /anaconda/bin/f2py -m fortmod -c ${PROJECT_SOURCE_DIR}/f2py/simple.f90 ${PROJECT_SOURCE_DIR}/f2py/arr1.f90 ${PROJECT_SOURCE_DIR}/f2py/arr2.f90
)

# DEPENDS ${PROJECT_SOURCE_DIR}/simple.f90 ${PROJECT_SOURCE_DIR}/simple.f90 ${PROJECT_SOURCE_DIR}/arr1.f90 ${PROJECT_SOURCE_DIR}/arr2.f90

