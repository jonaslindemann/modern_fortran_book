program optional_arguments

	implicit none
	
	call order_icecream(2)
	call order_icecream(2, 1)
	call order_icecream(4, 4, 2)
	call order_icecream(4, topping=3)
	
contains

subroutine order_icecream(number, flavor, topping)
	
	integer :: number
	integer, optional :: flavor
	integer, optional :: topping
	
	print *, number, 'icecreams ordered.'
	
	if (present(flavor)) then
		print *, 'Flavor is ', flavor
	else
		print *, 'No flavor was given.'
	end if
	
	if (present(topping)) then
		print *, 'Topping is ', topping
	else
		print *, 'No topping was given.'
	end if
	
end subroutine order_icecream

end program optional_arguments 