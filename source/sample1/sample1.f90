program sample1

	integer, parameter :: ap=selected_real_kind(15,300)
	real(kind=ap) :: x, y
	real(kind=ap) :: k(20,20)

	x = 6.0_ap
	y = 0.25_ap

	write(*,*) x
	write(*,*) y
	write(*,*) ap

    call myproc(k)

	write(*,*) k(1,1)

contains

subroutine myproc(k)
	
	integer, parameter :: ap=selected_real_kind(15,300)
	real(kind=ap) :: k(20,20)

	k=0.0_ap
	k(1,1) = 42.0_ap

	return

end subroutine myproc

end program sample1

