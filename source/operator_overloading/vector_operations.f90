module vector_operations

    use mf_datatypes

	type vector
        real(dp) :: components(3)
	end type vector
	
	interface operator(+)
		module procedure vector_plus_vector
	end interface

contains

type(vector) function vector_plus_vector(v1, v2)

	type(vector), intent(in) :: v1, v2
	vector_plus_vector%components = v1%components + v2%components
	
end function vector_plus_vector

end module vector_operations
