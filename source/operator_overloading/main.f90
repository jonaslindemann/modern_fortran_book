program operator_overloading

	use vector_operations

	implicit none

	type(vector) :: v1
	type(vector) :: v2
	type(vector) :: v
	
	v1%components = (/1.0, 0.0, 0.0/)
	v2%components = (/0.0, 1.0, 0.0/)
	
	v = v1 + v2
	
	print *, v

end program operator_overloading