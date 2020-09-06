subroutine vatan2(y,x,angle)

	!dec\$attributes dllexport, stdcall :: vatan2
	!dec\$attributes reference :: angle
	!dec\$attributes value :: x
	!dec\$attributes value :: y

	real(8) :: y, x, angle

	angle = atan2(y,x)
	
	return

end subroutine vatan2
