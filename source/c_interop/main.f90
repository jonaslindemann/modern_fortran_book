program c_interop

	use iso_c_binding

	implicit none
	
	integer(c_int) :: a
	real(c_float) :: b
	real(c_double) :: c
	
	a = 42
	b = 42.0_c_float
	c = 84.0_c_double
	
	print *, a, b, c

end program c_interop