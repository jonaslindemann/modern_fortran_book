program loop2

    use mf_datatypes

    implicit none

    real(dp) :: x, f

    x = 0.0_dp
    do while (x<1.05_dp)
        f = sin(x)
        x = x + 0.1_dp
        write(*,*) x, f
    end do

end program loop2
