program module_sample

	use truss

	implicit none

	real(ap) :: ex(2), ey(2), ez(2), ep(2)
    real(ap) :: Ke(6,6)

    ep(:) = (/ 1.0_ap, 1.0_ap /)
    ex(:) = (/ 0.0_ap, 1.0_ap /)
    ey(:) = (/ 0.0_ap, 1.0_ap /)
    ez(:) = (/ 0.0_ap, 1.0_ap /)

	call bar3e(ex,ey,ez,ep,Ke)
	call writeMatrix(Ke)

	stop

end program module_sample
