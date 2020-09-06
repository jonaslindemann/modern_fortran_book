module utils

use datatypes

interface print_matrix
    module procedure print_matrix_d, print_matrix_s
end interface

interface print_vector
    module procedure print_vector_d, print_vector_s
end interface

interface rand_mat
    module procedure rand_mat_d, rand_mat_s
end interface

interface rand_vec
    module procedure rand_vec_d, rand_vec_s
end interface

integer, private :: field_width = 10
integer, private :: field_decimals = 4
character :: field_code(1) = 'G'

contains

subroutine set_print_format(width, decimals, code)

    integer, optional :: width
    integer, optional :: decimals
    character, optional :: code(1)

    if (present(width)) then
        field_width = width
    end if

    if (present(decimals)) then
        field_decimals = decimals
    end if

    if (present(code)) then
        field_code = code
    end if

end subroutine set_print_format

subroutine print_matrix_d(A, name)

    real(dp), intent(in) :: A(:,:)
    character(*), intent(in), optional :: name
    integer :: rows, cols, slen
    integer :: i, j
    character(255) :: fmt
    character(255) :: sfmt

    rows = size(A,1)
    cols = size(A,2)
    slen = len_trim(name)

    if (slen<10) then
        write(sfmt, '(A,I1,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else if (slen<100) then
        write(sfmt, '(A,I2,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else
        write(sfmt, '(A,I3,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    end if

    if (cols<10) then
        if (field_width<10) then
            write(fmt, '(A,I1,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I1,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else if (cols<100) then
        if (field_width<10) then
            write(fmt, '(A,I2,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I2,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else
        if (field_width<10) then
            write(fmt, '(A,I3,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I3,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    end if

    !write(*,'(TL1,A)') repeat('-', cols*field_width)
    print*,''
    if (present(name)) then
        write(*,sfmt) 'Matrix ',trim(name),' (',rows, ' x ', cols, ') DP'
    else
        write(*,'(TL1,A,I3,A,I3,A)') 'Matrix (',rows, ' x ', cols, ') DP'
    end if
    write(*,'(TL1,A)') repeat('-', cols*field_width)


    do i=1,rows
        write(*,fmt) (A(i,j), j=1,cols)
    end do

    write(*,'(TL1,A)') repeat('-', cols*field_width)

end subroutine print_matrix_d

subroutine print_matrix_s(A, name)

    real(sp), intent(in) :: A(:,:)
    character(*), intent(in), optional :: name
    integer :: rows, cols, slen
    integer :: i, j
    character(255) :: fmt
    character(255) :: sfmt

    rows = size(A,1)
    cols = size(A,2)
    slen = len_trim(name)

    if (slen<10) then
        write(sfmt, '(A,I1,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else if (slen<100) then
        write(sfmt, '(A,I2,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else
        write(sfmt, '(A,I3,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    end if

    if (cols<10) then
        if (field_width<10) then
            write(fmt, '(A,I1,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I1,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else if (cols<100) then
        if (field_width<10) then
            write(fmt, '(A,I2,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I2,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else
        if (field_width<10) then
            write(fmt, '(A,I3,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I3,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    end if


    print*,''
    if (present(name)) then
        write(*,sfmt) 'Matrix ',trim(name),' (',rows, ' x ', cols, ') SP'
    else
        write(*,'(TL1,A,I3,A,I3,A)') 'Matrix (',rows, ' x ', cols, ') SP'
    end if
    write(*,'(TL1,A)') repeat('-', cols*field_width)


    do i=1,rows
        write(*,fmt) (A(i,j), j=1,cols)
    end do

    write(*,'(TL1,A)') repeat('-', cols*field_width)

end subroutine print_matrix_s

subroutine print_vector_d(A, name)

    real(dp), intent(in) :: a(:)
    character(*), intent(in), optional :: name
    integer :: cols, slen
    integer :: i
    character(255) :: fmt
    character(255) :: sfmt

    cols = size(A,1)
    slen = len_trim(name)

    if (slen<10) then
        write(sfmt, '(A,I1,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else if (slen<100) then
        write(sfmt, '(A,I2,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else
        write(sfmt, '(A,I3,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    end if

    if (cols<10) then
        if (field_width<10) then
            write(fmt, '(A,I1,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I1,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else if (cols<100) then
        if (field_width<10) then
            write(fmt, '(A,I2,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I2,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else
        if (field_width<10) then
            write(fmt, '(A,I3,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I3,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    end if

    print*, ''
    if (present(name)) then
        write(*,sfmt) 'Vector ',trim(name),' (',cols,') DP'
    else
        write(*,'(TL1,A,I3,A)') 'Vector (',cols,')'
    end if
    write(*,'(TL1,A)') repeat('-', cols*field_width)


    write(*,fmt) (a(i), i=1,cols)

    write(*,'(TL1,A)') repeat('-', cols*field_width)

end subroutine print_vector_d

subroutine print_vector_s(A, name)

    real(sp), intent(in) :: a(:)
    character(*), intent(in), optional :: name
    integer :: cols, slen
    integer :: i
    character(255) :: fmt
    character(255) :: sfmt

    cols = size(A,1)
    slen = len_trim(name)

    if (slen<10) then
        write(sfmt, '(A,I1,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else if (slen<100) then
        write(sfmt, '(A,I2,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    else
        write(sfmt, '(A,I3,A)') '(TL1,A,A',slen,',A,I3,A,I3,A)'
    end if

    if (cols<10) then
        if (field_width<10) then
            write(fmt, '(A,I1,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I1,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else if (cols<100) then
        if (field_width<10) then
            write(fmt, '(A,I2,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I2,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    else
        if (field_width<10) then
            write(fmt, '(A,I3,A,I1,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        else
            write(fmt, '(A,I3,A,I2,A,I1,A)') '(', cols, field_code, field_width, '.', field_decimals, ')'
        end if
    end if

    print*, ''
    if (present(name)) then
        write(*,sfmt) 'Vector ',trim(name),' (',cols,') SP'
    else
        write(*,'(TL1,A,I3,A)') 'Vector (',cols,')'
    end if
    write(*,'(TL1,A)') repeat('-', cols*field_width)


    write(*,fmt) (a(i), i=1,cols)

    write(*,'(TL1,A)') repeat('-', cols*field_width)

end subroutine print_vector_s

subroutine rand_mat_d(A, randMin, randMax)

    real(dp), intent(inout) :: A(:,:)
    real(dp), intent(in) :: randMin, randMax

    call random_number(A)

    !    min ---- max

    A = randMin + (randMax-randMin) * A

end subroutine rand_mat_d

subroutine rand_mat_s(A, randMin, randMax)

    real(sp), intent(inout) :: A(:,:)
    real(sp), intent(in) :: randMin, randMax

    call random_number(A)

    !    min ---- max

    A = randMin + (randMax-randMin) * A

end subroutine rand_mat_s

subroutine rand_vec_d(a, randMin, randMax)

    real(dp), intent(inout) :: a(:,:)
    real(dp), intent(in) :: randMin, randMax

    call random_number(a)

    !    min ---- max

    a = randMin + (randMax-randMin) * a

end subroutine rand_vec_d

subroutine rand_vec_s(a, randMin, randMax)

    real(sp), intent(inout) :: a(:)
    real(sp), intent(in) :: randMin, randMax

    call random_number(a)

    !    min ---- max

    a = randMin + (randMax-randMin) * a

end subroutine rand_vec_s

subroutine init_rand()
    integer :: values(1:8), k
    integer, dimension(:), allocatable :: seed
    real(real64) :: r
    call date_and_time(values=values)
    call random_seed(size=k)
    allocate(seed(1:k))
    seed(:) = values(8)
    call random_seed(put=seed)
end subroutine

end module utils
