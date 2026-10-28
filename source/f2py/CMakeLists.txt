find_package(Python COMPONENTS Interpreter REQUIRED)

# f2py's meson backend cannot handle absolute source paths containing spaces,
# so the sources are copied next to the build and passed by name.

set(F2PY_SOURCES simple.f90 matrix.f90)

foreach(src IN LISTS F2PY_SOURCES)
    configure_file(${src} ${CMAKE_CURRENT_BINARY_DIR}/${src} COPYONLY)
endforeach()

add_custom_target(
    fortmod ALL
    COMMAND ${Python_EXECUTABLE} -m numpy.f2py -c -m fortmod ${F2PY_SOURCES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM
)
