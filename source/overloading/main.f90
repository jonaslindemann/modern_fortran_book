program overloading

    use mf_datatypes
    use special

    implicit none

    integer  :: a = 42
    real(dp) :: b = 42.0_8

    a = func(a)
    b = func(b)

    print *, a
    print *, b
	
end program overloading
