program strings2

	implicit none

	integer :: i
	character(20) :: c

	c = '5'
	read(c,'(I5)') i
	write(*,*) i 

	i = 42
	write(c,'(I5)') i
	write(*,*) c

	stop

end program strings2