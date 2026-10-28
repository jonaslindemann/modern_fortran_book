module geometry

    use iso_c_binding, only: c_int, c_double, c_char

    implicit none

    type, bind(C) :: point
        real(c_double) :: x
        real(c_double) :: y
    end type point

    interface

        function distance(a, b) result(d) bind(C, name='distance')
            import :: point, c_double
            type(point), value, intent(in) :: a, b
            real(c_double) :: d
        end function distance

        subroutine translate(p, n, dx, dy) bind(C, name='translate')
            import :: point, c_int, c_double
            type(point), intent(inout) :: p(*)
            integer(c_int), value, intent(in) :: n
            real(c_double), value, intent(in) :: dx, dy
        end subroutine translate

        subroutine c_greet(name) bind(C, name='greet')
            import :: c_char
            character(kind=c_char), intent(in) :: name(*)
        end subroutine c_greet

    end interface

contains

    subroutine greet(name)

        use iso_c_binding, only: c_null_char

        character(len=*), intent(in) :: name

        call c_greet(trim(name) // c_null_char)

    end subroutine greet

end module geometry

program fortran_calls_c

    use geometry

    implicit none

    type(point) :: p(3)

    p(1) = point(0.0d0, 0.0d0)
    p(2) = point(3.0d0, 4.0d0)
    p(3) = point(6.0d0, 8.0d0)

    print '(a, f6.2)', 'distance = ', distance(p(1), p(2))

    call translate(p, size(p), 1.0d0, -1.0d0)

    print '(a, 6f6.2)', 'translated = ', p

    call greet('Fortran')

end program fortran_calls_c
