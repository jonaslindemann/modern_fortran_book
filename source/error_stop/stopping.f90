program stopping

    use iso_fortran_env, only: error_unit

    implicit none

    integer :: n

    n = requested_size()

    if (n <= 0) then
        write(error_unit, *) 'error: size must be positive, got ', n
        error stop 1
    end if

    write(*,*) 'allocating ', n, ' elements'

    stop 'done'

contains

integer function requested_size()

    ! In a real program this value would come from the command line,
    ! an input file or a namelist.

    requested_size = 10

end function requested_size

end program stopping
