program dynamic_fcodes

	use array_utils

	implicit none
	
	real(8) :: A(6,6)
	
	A = 42.0_8
	
	call writeArray(A)
	
end program dynamic_fcodes