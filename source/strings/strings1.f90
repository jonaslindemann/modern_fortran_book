program strings

    implicit none

    character(4) :: c1
    character(5) :: c2
    character(4) :: c3
    character(9) :: c

    c1 = 'Hej '
    c2 = 'hopp!'
    c = c1//c2     ! Concatenation
    c3 = c(5:8)    ! Substring

    write(*,*) c
    write(*,*) c3

    stop

end program strings
