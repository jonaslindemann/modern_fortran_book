program module_sample

    use mf_datatypes
    use mf_utils
	use truss

	implicit none

	real(dp) :: ex(2), ey(2), ez(2), ep(2)
	real(dp), allocatable :: Ke(:,:)

	ep(1) = 1.0_dp
	ep(2) = 1.0_dp
	ex(1) = 0.0_dp
	ex(2) = 1.0_dp
	ey(1) = 0.0_dp
	ey(2) = 1.0_dp
	ez(1) = 0.0_dp
	ez(2) = 1.0_dp

	allocate(Ke(6,6))

	call bar3e(ex,ey,ez,ep,Ke)
    call print_matrix(Ke)

	deallocate(Ke)

	stop

end program module_sample
