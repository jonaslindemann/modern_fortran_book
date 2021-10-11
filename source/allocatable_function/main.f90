program allocatable_function

    implicit none

    real :: A(20)

    A = create_vector(20)
    print *, size(A,1)
	
contains

function create_vector(n)

    real, allocatable, dimension(:) :: create_vector
    integer, intent(in) :: n

    allocate(create_vector(n))
	
end function create_vector
	
end program allocatable_function
