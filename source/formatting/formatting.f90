program formatting

    implicit none

    integer, parameter :: dp = &
            selected_real_kind(15,300)

    write(*,'(A15)') '123456789012345'
    write(*,'(G15.4)') 5.675789_dp
    write(*,'(G15.4)') 0.0675789_dp
    write(*,'(E15.4)') 0.675779_dp
    write(*,'(F15.4)') 0.675779_dp
    write(*,*)         0.675779_dp
    write(*,'(I15)')   156
    write(*,*) 156

    stop

end program formatting
