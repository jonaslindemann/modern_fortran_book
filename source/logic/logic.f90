program logic

	implicit none

	integer :: x
	logical :: flag

	! Read an integer from standard input

	write(*,*) 'Enter an integer value.'
	read(*,*) x

	! Correct value to the interval 0-1000

	flag = .FALSE.

	if (x>1000) then
		x = 1000
		flag = .TRUE.
	end if
	
	if (x<0) then
		x = 0
		flag = .TRUE.
	end if
	
	! If flag is .TRUE. the input value
	! has been corrected.

	if (flag) then
		write(*,'(a,I4)') 'Corrected value = ', x
	else
		write(*,'(a,I4)') 'Value = ', x
	end if

	stop

end program logic
