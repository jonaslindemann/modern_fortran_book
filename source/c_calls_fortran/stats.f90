module stats

    use iso_c_binding, only: c_int, c_double

    implicit none

contains

    function mean(x, n) result(m) bind(C, name='stats_mean')

        integer(c_int), value, intent(in) :: n
        real(c_double), intent(in) :: x(n)
        real(c_double) :: m

        m = sum(x) / n

    end function mean

    subroutine scale(x, n, factor) bind(C, name='stats_scale')

        integer(c_int), value, intent(in) :: n
        real(c_double), intent(inout) :: x(n)
        real(c_double), value, intent(in) :: factor

        x = factor * x

    end subroutine scale

    subroutine row_sums(a, rows, cols, sums) bind(C, name='stats_row_sums')

        integer(c_int), value, intent(in) :: rows, cols
        real(c_double), intent(in) :: a(cols, rows)
        real(c_double), intent(out) :: sums(rows)

        sums = sum(a, dim=1)

    end subroutine row_sums

end module stats
