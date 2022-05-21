program operator_overloading

    use mf_datatypes
	use vector_operations

	implicit none

	type(vector) :: v1
	type(vector) :: v2
	type(vector) :: v
	
    v1%components = (/1.0_dp, 0.0_dp, 0.0_dp/)
    v2%components = (/0.0_dp, 1.0_dp, 0.0_dp/)
	
	v = v1 + v2

	print *, v

end program operator_overloading
