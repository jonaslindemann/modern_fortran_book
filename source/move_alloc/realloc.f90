program realloc

    use iso_fortran_env, only: real64

    implicit none

    real(real64), allocatable :: a(:), bigger(:)

    ! An allocatable array is allocated by the assignment itself.

    a = [1.0_real64, 2.0_real64, 3.0_real64]

    write(*,*) 'size after first assignment :', size(a)

    ! The left hand side is reallocated to fit the right hand side.

    a = [a, 4.0_real64]

    write(*,*) 'size after appending        :', size(a)

    ! Growing an array explicitly, without copying it twice.

    allocate(bigger(2*size(a)))

    bigger = 0.0_real64
    bigger(1:size(a)) = a

    call move_alloc(bigger, a)

    write(*,*) 'size after move_alloc       :', size(a)
    write(*,*) 'bigger still allocated      :', allocated(bigger)
    write(*,'(A,8F5.1)') ' contents                    :', a

end program realloc
