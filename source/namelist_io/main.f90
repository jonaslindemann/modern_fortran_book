program namelist_io

	implicit none
	
	integer, parameter :: ir = 15
	integer, parameter :: iw = 16
	integer :: no_of_eggs, litres_of_milk, kilos_of_butter, list(5)
	namelist /food/ no_of_eggs, litres_of_milk, kilos_of_butter, list
	
	list = 0
	
	open(unit=ir, file='food.txt', status='old')
	read(ir, nml=food)
	print *, no_of_eggs, litres_of_milk, kilos_of_butter
	read(ir, nml=food)
	print *, no_of_eggs, litres_of_milk, kilos_of_butter
	close(unit=ir)
		
	open(unit=iw, file='food2.txt', status='new')
	write(iw, nml=food)
	close(unit=iw)

end program namelist_io