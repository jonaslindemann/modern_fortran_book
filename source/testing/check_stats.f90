program check_stats

    use iso_fortran_env, only: real64, error_unit
    use stats, only: mean, variance

    implicit none

    real(real64), parameter :: tol = 1.0e-12_real64
    real(real64) :: x(5)

    x = [2.0_real64, 4.0_real64, 4.0_real64, 4.0_real64, 6.0_real64]

    call check(abs(mean(x) - 4.0_real64) < tol, 'mean of the sample')
    call check(abs(variance(x) - 2.0_real64) < tol, 'variance of the sample')
    call check(abs(mean([1.0_real64]) - 1.0_real64) < tol, 'mean of one element')

    write(*,*) 'all tests passed'

contains

subroutine check(condition, name)

    logical, intent(in) :: condition
    character(len=*), intent(in) :: name

    if (.not. condition) then
        write(error_unit, *) 'FAILED: ', name
        error stop 1
    end if

    write(*,*) 'ok: ', name

end subroutine check

end program check_stats
