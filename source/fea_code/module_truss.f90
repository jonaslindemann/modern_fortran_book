module truss

    ! Used modules

    use mf_datatypes
    use mf_utils

    ! Public variable declarations

    ! Variables that are visible for other programs
    ! and modules

contains

subroutine bar3e(ex,ey,ez,ep,Ke)

    implicit none


    real(dp) :: ex(2), ey(2), ez(2), ep(2)
    real(dp) :: Ke(6,6)

    real(dp) :: nxx, nyx, nzx
    real(dp) :: L, E, A
    real(dp) :: Kel(2,2)
    real(dp) :: G(2,6)

    ! Calculate directional cosines

    L = sqrt( (ex(2)-ex(1))**2 + (ey(2)-ey(1))**2 &
        + (ez(2)-ez(1))**2 )

    nxx = (ex(2)-ex(1))/L
    nyx = (ey(2)-ey(1))/L
    nzx = (ez(2)-ez(1))/L

    ! Calculate local stiffness matrix

    Kel(1,:) = (/  1.0_dp , -1.0_dp  /)
    Kel(2,:) = (/ -1.0_dp,   1.0_dp  /)

    Kel = Kel * (ep(1)*ep(2)/L)

    G(1,:) = (/ nxx, nyx, nzx, &
        0.0_dp, 0.0_dp, 0.0_dp /)
    G(2,:) = (/ 0.0_dp, 0.0_dp, 0.0_dp, &
        nxx, nyx, nzx /)

    ! Calculate transformed stiffness matrix

    Ke = matmul(matmul(transpose(G),Kel),G)

    return

end subroutine bar3e

end module truss
