module stats

    use iso_fortran_env, only: real64

    implicit none

    private

    public :: mean, variance

contains

pure real(real64) function mean(x) result(m)

    real(real64), intent(in) :: x(:)

    m = sum(x) / real(size(x), real64)

end function mean

pure real(real64) function variance(x) result(v)

    real(real64), intent(in) :: x(:)

    v = sum((x - mean(x))**2) / real(size(x) - 1, real64)

end function variance

end module stats
