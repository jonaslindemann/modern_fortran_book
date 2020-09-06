program error_handling

    implicit none

    integer, parameter :: ir = 15
    integer :: a

    open(unit=ir, file='test.txt', status='old', err=101)
    read(ir,*,err=102) a
    close(unit=ir,err=103)

    stop

101 print *, 'An error occured when opening the file.'

    stop

102 print *, 'An error occured when reading the file.'

    stop

103 print *, 'An error occured when closing the file.'

    stop

end program error_handling
