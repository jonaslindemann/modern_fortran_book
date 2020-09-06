program module_sample

	use truss

	implicit none

	real(ap) :: ex(2), ey(2), ez(2), ep(2)
	real(ap), allocatable :: Ke(:,:)

	ep(1) = 1.0_ap
	ep(2) = 1.0_ap
	ex(1) = 0.0_ap
	ex(2) = 1.0_ap
	ey(1) = 0.0_ap
	ey(2) = 1.0_ap
	ez(1) = 0.0_ap
	ez(2) = 1.0_ap

	allocate(Ke(6,6))

	call bar3e(ex,ey,ez,ep,Ke)
	call writeMatrix(Ke)

	deallocate(Ke)

	stop

end program module_sample
