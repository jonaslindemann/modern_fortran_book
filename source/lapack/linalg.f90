module linalg

use datatypes
use utils

interface solve
    module procedure solve_dp, solve_sp
end interface solve

integer, private :: err

contains

function error_status() result(errStat)

    integer :: errStat

    errStat = err

end function error_status

subroutine solve_dp(A, b)

    real(dp), intent(inout) :: A(:,:)
    real(dp), intent(inout) :: b(:,:)
    integer :: ipiv(size(A,1))
    integer :: lda, ldb, n, nrhs

    lda = size(A,1)
    ldb = size(B,1)
    n = size(A,1)
    nrhs = size(B,2)

    call DGESV(n, nrhs, A, lda, ipiv, b, ldb, err)

end subroutine solve_dp

subroutine solve_sp(A, b)

    real(sp), intent(inout) :: A(:,:)
    real(sp), intent(inout) :: b(:,:)
    integer :: lda, ldb, n, nrhs

    lda = size(A,1)
    ldb = size(B,1)
    n = size(A,1)
    nrhs = size(B,2)

    call SGESV(n, nrhs, A, n, ipiv, b, n, err)

end subroutine solve_sp

end module linalg
