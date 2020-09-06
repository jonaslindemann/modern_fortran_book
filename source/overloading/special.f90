module special

interface func
	module procedure ifunc, rfunc
end interface

contains

integer function ifunc(x)
	
	integer, intent(in) :: x
	ifunc = x * 42
	
end function ifunc

real(8) function rfunc(x)
	
	real(8), intent(in) :: x
	rfunc = x / 42.0_8
	
end function rfunc

end module special 