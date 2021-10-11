program module_sample

    use mf_datatypes
    use mf_utils
    use truss

    implicit none

    real(dp) :: ex(2), ey(2), ez(2), ep(2)
    real(dp) :: Ke(6,6)

    ep(:) = (/ 1.0_dp, 1.0_dp /)
    ex(:) = (/ 0.0_dp, 1.0_dp /)
    ey(:) = (/ 0.0_dp, 1.0_dp /)
    ez(:) = (/ 0.0_dp, 1.0_dp /)

    call bar3e(ex, ey, ez, ep, Ke)
    call print_matrix(Ke, 'Ke')

    stop

end program module_sample
