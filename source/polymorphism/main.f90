program polymorphism

    use iso_fortran_env, only: real64
    use shapes, only: circle_class, rectangle_class, describe

    implicit none

    type(circle_class) :: c
    type(rectangle_class) :: r

    c % radius = 2.0_real64

    r % width = 3.0_real64
    r % height = 4.0_real64

    call describe(c)
    call describe(r)
    call describe(42)
    call describe('a string')
    call describe((1.0, 2.0))

end program polymorphism
