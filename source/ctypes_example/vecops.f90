module vecops

    use iso_c_binding, only: c_int, c_double

    implicit none

contains

    function dot(x, y, n) result(d) bind(C, name='vec_dot')

        integer(c_int), value, intent(in) :: n
        real(c_double), intent(in) :: x(n), y(n)
        real(c_double) :: d

        d = dot_product(x, y)

    end function dot

    subroutine axpy(a, x, y, n) bind(C, name='vec_axpy')

        real(c_double), value, intent(in) :: a
        integer(c_int), value, intent(in) :: n
        real(c_double), intent(in) :: x(n)
        real(c_double), intent(inout) :: y(n)

        y = a * x + y

    end subroutine axpy

    subroutine mat_mul(a, b, c, m, k, n) bind(C, name='mat_mul')

        integer(c_int), value, intent(in) :: m, k, n
        real(c_double), intent(in) :: a(m, k), b(k, n)
        real(c_double), intent(out) :: c(m, n)

        c = matmul(a, b)

    end subroutine mat_mul

end module vecops
