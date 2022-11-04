program allocatable_function

    implicit none

    real, allocatable, dimension(:) :: A

    A = create_vector(30)
    print *, size(A,1)
	
contains

function create_vector(n)

    real, allocatable, dimension(:) :: create_vector
    integer, intent(in) :: n

    allocate(create_vector(n))
	
end function create_vector
	
end program allocatable_function
