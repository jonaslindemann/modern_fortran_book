module points
	type point
		real :: x, y
	end type point
	
	interface 
		real module function point_dist(a, b)
			type(point), intent(in) :: a, b
		end function point_dist
	end interface
end module points
	