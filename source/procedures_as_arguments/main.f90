program procedures_as_arguments

    use mf_datatypes
	use utils

	implicit none
	
    call tabulate(0.0_dp, 3.14_dp, 0.1_dp, myfunc)
	
end program procedures_as_arguments

