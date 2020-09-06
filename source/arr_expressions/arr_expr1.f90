program arr_expr1

    use utils

    real(sp) :: a(10,20), b(10,20), c(10,20)
    real(sp) :: u(5), v(5)

    call init_rand()
    call set_print_format(10, 4, 'F')
    call rand_mat(a, 0.0_sp, 1.0_sp)
    call rand_mat(b, 1.0_sp, 10.0_sp)
    call rand_vec(v, 0.0_sp, 1.0_sp)

    c = a/b

    call print_matrix(a, 'a')
    call print_matrix(b, 'b')
    call print_matrix(c, 'c')

    u = v + 1.0_sp

    call print_vector(v, 'v')
    call print_vector(u, 'u')

    u = 5.0_sp/v + a(1:5,5)

    call print_vector(u, 'u')

end program arr_expr1
