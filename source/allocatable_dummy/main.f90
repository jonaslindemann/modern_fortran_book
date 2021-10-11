program allocatable_dummy

    implicit none

    real, allocatable :: A(:,:)

    call createArray(A)

    print *, size(A,1), size(A,2)

    deallocate(A)

contains

subroutine createArray(A)
	
    real, allocatable, intent(out) :: A(:,:)

    allocate(A(20,20))
	
end subroutine createArray
	
end program allocatable_dummy
