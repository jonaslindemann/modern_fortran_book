program concurrent

    use iso_fortran_env, only: real64

    implicit none

    integer, parameter :: n = 8
    real(real64) :: x(n), y(n)
    integer :: i

    do concurrent (i = 1:n)
        x(i) = real(i, real64)
    end do

    y = 0.0_real64

    do concurrent (i = 1:n, mod(i, 2) == 0)
        y(i) = sqrt(x(i))
    end do

    do i = 1, n
        write(*,'(I3,2F10.4)') i, x(i), y(i)
    end do

end program concurrent
