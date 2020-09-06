subroutine forsum(a, b, c) bind(C, name='forsum')

	use iso_c_binding
	
	real(c_double), value :: a, b
	real(c_double)        :: c 

	c = a + b

end subroutine forsum
