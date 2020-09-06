program lapack_newstyle

    use datatypes
    use linalg
    use utils

    implicit none

    integer :: i, j, info, n, nrhs

    real(dp), allocatable :: a(:,:), b(:,:)
    real(dp) :: start, finish
    integer :: wstart, wfinish, cr
    real(dp) :: rate
    real(dp) :: flops
    real(dp) :: wall_time

    n = 20000
    nrhs = 1

    allocate( a(n,n), b(n,nrhs) )

    call init_rand()
    call rand_mat(a,10.0D0,50.0D0)

    do j = 1, nrhs; b(:,j) = sum(a, dim=2)*j; enddo

    call system_clock(count_rate=cr)
    rate = cr
    call system_clock(wstart)
    call cpu_time(start)
    call solve(a, b)
    call cpu_time(finish)
    call system_clock(wfinish)

    wall_time = (wfinish-wstart)/rate

    print '("Error =",i3)', error_status()
    print '("CPU Time  =",f10.3," seconds")', finish - start
    print '("Wall Time  =",f10.3," seconds")', wall_time

    flops = 0.67_dp*real(n)**3 + real(n)**2
    print *, flops
    print '("GFlop/s = ",f16.3)', (flops * 1e-9) / wall_time

end program lapack_newstyle
