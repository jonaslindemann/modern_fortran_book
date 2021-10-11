program undef1

    use mf_datatypes

    implicit none

    real(dp) :: a, b
    character(40) :: s1, s2

    a = 42.0_dp ! --- Defined
    s1 = 'My defined string'

    print*, a
    print*, b
    print*, s1
    print*, s2

end program undef1
