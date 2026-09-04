program pure_elemental

    use iso_fortran_env, only: real64
    use temperatures, only: to_kelvin, clamp

    implicit none

    real(real64) :: readings(5)

    readings = [-300.0_real64, -20.0_real64, 0.0_real64, 20.0_real64, 300.0_real64]

    write(*,'(A,5F9.2)') ' readings :', readings

    ! An elemental function applies to each element of the array.

    write(*,'(A,5F9.2)') ' clamped  :', clamp(readings, -50.0_real64, 50.0_real64)

    ! A pure function takes a scalar and returns a scalar.

    write(*,'(A,F9.2)') ' 20 C in kelvin :', to_kelvin(20.0_real64)

end program pure_elemental
