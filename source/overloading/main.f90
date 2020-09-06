program overloading

	use special
	
	implicit none
	
	integer :: a = 42
	real(8) :: b = 42.0_8
	
	a = func(a)
	b = func(b)
	
	print *, a
	print *, b 
	
end program overloading
