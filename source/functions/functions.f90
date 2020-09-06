program function_sample

	implicit none

	integer, parameter :: ap = selected_real_kind(15,300)
	
	integer :: i, j
	
	real(ap) :: x1, x2, y1, y2, z1, z2
	real(ap) :: nx, ny, nz
	real(ap) :: L, E, A
	real(ap) :: Kel(2,2)
	real(ap) :: Ke(6,6)
	real(ap) :: G(2,6)

	! Initiate scalar values

	E = 1.0_ap
	A = 1.0_ap
	x1 = 0.0_ap
	x2 = 1.0_ap
	y1 = 0.0_ap
	y2 = 1.0_ap
	z1 = 0.0_ap
	z2 = 1.0_ap

	! Calcuate directional cosines

	L = sqrt( (x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2 )
	nx = (x2-x1)/L
	ny = (y2-y1)/L
	nz = (z2-z1)/L

	! Calucate local stiffness matrix

	Kel(1,:) = (/  1.0_ap , -1.0_ap  /)
	Kel(2,:) = (/ -1.0_ap,   1.0_ap  /)

	Kel = Kel * (E*A/L)

	G(1,:) = (/ nx, ny, nz, 0.0_ap, 0.0_ap, 0.0_ap /)
	G(2,:) = (/ 0.0_ap, 0.0_ap, 0.0_ap, nx, ny, nz /)

	! Calculate transformed stiffness matrix

	Ke = matmul(matmul(transpose(G),Kel),G)

	! Print matrix

	do i=1,6
		write(*,'(6G10.3)') (Ke(i,j), j=1,6)
	end do

	stop

end program function_sample