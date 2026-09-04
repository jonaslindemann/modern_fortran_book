program omp_sum

    use iso_fortran_env, only: real64
    !$ use omp_lib

    implicit none

    integer, parameter :: n = 10000000
    real(real64) :: total, exact
    integer :: i

    !$ write(*,*) 'threads available :', omp_get_max_threads()

    total = 0.0_real64

    !$omp parallel do reduction(+:total)
    do i = 1, n
        total = total + 1.0_real64 / real(i, real64)**2
    end do
    !$omp end parallel do

    exact = acos(-1.0_real64)**2 / 6.0_real64

    write(*,*) 'sum       =', total
    write(*,*) 'pi**2 / 6 =', exact

end program omp_sum
