program function_sample

    implicit none

    integer, parameter :: dp = selected_real_kind(15,300)

    integer :: i, j

    real(dp) :: x1, x2, y1, y2, z1, z2
    real(dp) :: nx, ny, nz
    real(dp) :: L, E, A
    real(dp) :: Kel(2,2)
    real(dp) :: Ke(6,6)
    real(dp) :: G(2,6)

    ! Initiate scalar values

    E = 1.0_dp
    A = 1.0_dp
    x1 = 0.0_dp
    x2 = 1.0_dp
    y1 = 0.0_dp
    y2 = 1.0_dp
    z1 = 0.0_dp
    z2 = 1.0_dp

    ! Calcuate directional cosines

    L = sqrt( (x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2 )
    nx = (x2-x1)/L
    ny = (y2-y1)/L
    nz = (z2-z1)/L

    ! Calucate local stiffness matrix

    Kel(1,:) = (/  1.0_dp , -1.0_dp  /)
    Kel(2,:) = (/ -1.0_dp,   1.0_dp  /)

    Kel = Kel * (E*A/L)

    G(1,:) = (/ nx, ny, nz, 0.0_dp, 0.0_dp, 0.0_dp /)
    G(2,:) = (/ 0.0_dp, 0.0_dp, 0.0_dp, nx, ny, nz /)

    ! Calculate transformed stiffness matrix

    Ke = matmul(matmul(transpose(G),Kel),G)

    ! Print matrix

    do i=1,6
            write(*,'(6G10.3)') (Ke(i,j), j=1,6)
    end do

    stop

end program function_sample
