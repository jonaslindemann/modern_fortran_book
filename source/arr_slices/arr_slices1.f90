program arr_slices1

    use utils

    real(dp) :: A(10,10)
    real(dp) :: v(10)

    call init_rand()
    call set_print_format(10, 4, 'F')

    call rand_mat(A, 0.0_dp, 1.0_dp)
    call rand_vec(v, 0.0_dp, 1.0_dp)

    call print_matrix(A, 'a')
    print*, loc(A)

    call print_vector(v, 'c')
    print*, loc(v)

    call print_vector(A(:,1))
    print*, loc(A(:,1))

    call print_vector(A(1,:))
    print*, loc(A(1,:))

    call print_matrix(A(1:2,1:2))
    print*, loc(A(1:2,1:2))

    call print_matrix(A(1:6:2,1:6:2))
    print*, loc(A(1:6:2,1:6:2))

    call print_matrix(A(:,1:2))
    print*, loc(A(:,1:2))


end program arr_slices1
