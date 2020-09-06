program allocatable_function

	implicit none
	
	real :: A(20)
	
	A = createVector(20)
	print *, size(A,1)
	
contains

function createVector(n)

	real, allocatable, dimension(:) :: createVector 
	integer, intent(in) :: n
	
	allocate(createVector(n))
	
end function createVector
	
end program allocatable_function