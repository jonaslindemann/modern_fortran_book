module special

use mf_datatypes

interface func
	module procedure ifunc, rfunc
end interface

contains

integer function ifunc(x)
	
	integer, intent(in) :: x
	ifunc = x * 42
	
end function ifunc

real(dp) function rfunc(x)
	
    real(dp), intent(in) :: x
	rfunc = x / 42.0_8
	
end function rfunc

end module special 
