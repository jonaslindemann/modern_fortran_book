program dynamic_fcodes

    use array_utils

    implicit none

    real(8) :: A(9,9)

    A = 42.0_8
	
    call write_array(A)
	
end program dynamic_fcodes
