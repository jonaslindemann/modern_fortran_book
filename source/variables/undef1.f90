program undef1

    implicit none

    integer, parameter :: dp = selected_real_kind(15,300)

    real(dp) :: a, b
    character(40) :: s1, s2

    a = 42.0_dp ! --- Defined
    s1 = 'My defined string'

    print*, a
    print*, b
    print*, s1
    print*, s2

end program undef1
