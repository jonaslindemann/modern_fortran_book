program la_sgesv_example

    !  -- lapack95 example driver routine (version 1.0) --
    !     uni-c, denmark
    !     december, 1999
    !

    use datatypes
    use utils

    implicit none

    integer :: i, j, info, n, nrhs
    integer, allocatable :: ipiv(:)
    real(dp), allocatable :: a(:,:), aa(:,:), b(:,:), bb(:,:)

    !  .. "executable statements" ..

    call init_rand()

    n = 10
    nrhs = 4

    allocate( a(n,n), aa(n,n), b(n,nrhs), bb(n,nrhs), ipiv(n) )

    call rand_mat(aa,10.0D0,50.0D0)

    do j = 1, nrhs; bb(:,j) = sum( aa, dim=2)*j; enddo

    write(*,*) 'the matrix a:'
    call print_matrix(aa)

    write(*,*) 'the rhs matrix b:'
    call print_matrix(bb)

    write(*,*) 'call la_gesv( a, b )'
    a=aa; b=bb

    call DGESV(n, nrhs, a, n, ipiv, b, n, info)

    write(*,*) 'b - the solution vectors computed by la_gesv'
    call print_matrix(b)

    write(*,*)'ipiv on exit:', ipiv

    write(*,*)'info on exit:', info

end program la_sgesv_example
