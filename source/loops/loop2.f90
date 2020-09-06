program loop2

    implicit none

    integer, parameter :: rk = selected_real_kind(5,20)
    real(rk) :: x, f

    x = 0.0D0
    do while (x<1.05D0)
        f = sin(x)
        x = x + 0.1D0
        write(*,*) x, f
    end do

end program loop2
