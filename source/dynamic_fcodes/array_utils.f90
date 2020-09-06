module array_utils

contains

subroutine writeArray(A)

	real(8), dimension(:,:) :: A
	integer :: rows, cols, i, j
	character(255) :: fmt
		
	rows = size(A,1)
	cols = size(A,2)
		
	write(fmt, '(A,I1,A)') '(',cols, 'G8.3)'  

	do i=1,rows
		print fmt, (A(i,j), j=1,cols)
	end do
		
	return
	
end subroutine writeArray

end module array_utils