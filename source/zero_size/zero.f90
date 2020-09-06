program zero
	real,allocatable :: a(:)
	real :: b(0)
	
	allocate(a(0))

	print*, size(a)
	print*, size(b)

        print*, a(0)

        !print*, b(0)

end program zero
