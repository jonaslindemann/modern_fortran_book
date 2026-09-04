program kinds

    use iso_fortran_env, only: real32, real64, int32, int64, &
        output_unit, compiler_version

    implicit none

    real(real32) :: x32
    real(real64) :: x64
    integer(int32) :: small
    integer(int64) :: big

    x32 = 1.0_real32 / 3.0_real32
    x64 = 1.0_real64 / 3.0_real64

    small = huge(small)
    big = 2_int64**40

    write(output_unit, *) 'real32  1/3 =', x32
    write(output_unit, *) 'real64  1/3 =', x64
    write(output_unit, *) 'largest int32 =', small
    write(output_unit, *) '2**40 as int64 =', big

    write(output_unit, *) 'decimal digits in real64 =', precision(x64)
    write(output_unit, *) 'decimal exponent range   =', range(x64)

    write(output_unit, *) 'compiled by ', compiler_version()

end program kinds
