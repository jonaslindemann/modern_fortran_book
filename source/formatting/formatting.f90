program formatting

	implicit none

	integer, parameter :: ap = &
		selected_real_kind(15,300)

	write(*,'(A15)') '123456789012345'
	write(*,'(G15.4)') 5.675789_ap
	write(*,'(G15.4)') 0.0675789_ap
	write(*,'(E15.4)') 0.675779_ap
	write(*,'(F15.4)') 0.675779_ap
	write(*,*)         0.675779_ap 
	write(*,'(I15)')   156
	write(*,*) 156

	stop

end program formatting