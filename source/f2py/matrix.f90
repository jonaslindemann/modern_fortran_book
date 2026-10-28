module matrix

    use iso_c_binding, only: c_int, c_double

    implicit none

contains

    ! A[r,s] * B[s,t] = C[r,t]
    subroutine matrix_multiply(A, r, s, B, t, C)

        integer(c_int), intent(in) :: r, s, t
        real(c_double), intent(in) :: A(r, s)
        real(c_double), intent(in) :: B(s, t)
        real(c_double), intent(out) :: C(r, t)

        C = matmul(A, B)

    end subroutine matrix_multiply

    ! A[r,s] * B[s,t] = C[r,t], with C supplied by the caller
    subroutine matrix_multiply_inplace(A, r, s, B, t, C)

        integer(c_int), intent(in) :: r, s, t
        real(c_double), intent(in) :: A(r, s)
        real(c_double), intent(in) :: B(s, t)
        real(c_double), intent(inout) :: C(r, t)

        C = matmul(A, B)

    end subroutine matrix_multiply_inplace

    function frobenius_norm(A) result(norm)

        real(c_double), intent(in) :: A(:, :)
        real(c_double) :: norm

        norm = sqrt(sum(A**2))

    end function frobenius_norm

end module matrix
