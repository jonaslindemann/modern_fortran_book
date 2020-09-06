module utils

	implicit none

contains

real(8) function myfunc(x)
	real(8), intent(in) :: x
	
	myfunc = sin(x)
	
end function myfunc

subroutine tabulate(startInterval, endInterval, step, func)
	real(8), intent(in) :: startInterval, endInterval, step
	real(8) :: x
	
	interface 
		real(8) function func(x)
			real(8), intent(in) :: x
		end function func
	end interface
	
	x = startInterval
	
	do while (x<endInterval) 
		print *, x, func(x)
		x = x + step
	end do
	
	return
end subroutine tabulate

end module utils 
