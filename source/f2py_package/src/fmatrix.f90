module fmatrix

    use iso_c_binding, only: c_double

    implicit none

contains

    function frobenius_norm(A) result(norm)

        real(c_double), intent(in) :: A(:, :)
        real(c_double) :: norm

        norm = sqrt(sum(A**2))

    end function frobenius_norm

    subroutine scale(A, factor)

        real(c_double), intent(inout) :: A(:, :)
        real(c_double), intent(in) :: factor

        A = factor * A

    end subroutine scale

end module fmatrix
