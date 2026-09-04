program coarray_sum

    use iso_fortran_env, only: real64, output_unit

    implicit none

    integer, parameter :: n = 100

    real(real64) :: partial[*]
    real(real64) :: total
    integer :: me, images, i

    me = this_image()
    images = num_images()

    ! Every image sums its own stride of the range.

    partial = 0.0_real64

    do i = me, n, images
        partial = partial + real(i, real64)
    end do

    sync all

    ! Image 1 collects the partial sums by indexing into the other images.

    if (me == 1) then
        total = 0.0_real64
        do i = 1, images
            total = total + partial[i]
        end do
        write(output_unit, *) 'images        :', images
        write(output_unit, *) 'sum by hand   :', total
    end if

    ! The same reduction using a collective subroutine (Fortran 2018).

    total = partial
    call co_sum(total, result_image=1)

    if (me == 1) then
        write(output_unit, *) 'sum by co_sum :', total
    end if

end program coarray_sum
