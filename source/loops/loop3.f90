program loop3

    implicit none

    integer :: i

    do i=1, 1000
        if (i>50) then
            exit
        else if (i<10) then
            cycle
        end if
        print *,i
    end do

end program loop3
