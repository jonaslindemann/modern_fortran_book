program sample1

    integer, parameter :: dp=selected_real_kind(15,300)
    real(kind=dp) :: x, y
    real(kind=dp) :: k(20,20)

    x = 6.0_dp
    y = 0.25_dp

    write(*,*) x
    write(*,*) y
    write(*,*) dp

    call myproc(k)

    write(*,*) k(1,1)

contains

subroutine myproc(k)
	
    integer, parameter :: dp=selected_real_kind(15,300)
    real(kind=dp) :: k(20,20)

    k=0.0_dp
    k(1,1) = 42.0_dp

    return

end subroutine myproc

end program sample1

