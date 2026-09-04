module shapes

    use iso_fortran_env, only: real64

    implicit none

    private

    public :: shape_class, circle_class, rectangle_class, describe

    ! An abstract type cannot be instantiated. It only states what every
    ! shape must be able to do.

    type, abstract :: shape_class
    contains
        procedure(area_interface), deferred :: area
        procedure :: print => shape_print
    end type shape_class

    abstract interface

        real(real64) function area_interface(this) result(a)
            import :: shape_class, real64
            class(shape_class), intent(in) :: this
        end function area_interface

    end interface

    type, extends(shape_class) :: circle_class
        real(real64) :: radius = 1.0_real64
    contains
        procedure :: area => circle_area
    end type circle_class

    type, extends(shape_class) :: rectangle_class
        real(real64) :: width = 1.0_real64
        real(real64) :: height = 1.0_real64
    contains
        procedure :: area => rectangle_area
    end type rectangle_class

contains

real(real64) function circle_area(this) result(a)

    class(circle_class), intent(in) :: this

    a = acos(-1.0_real64) * this % radius**2

end function circle_area

real(real64) function rectangle_area(this) result(a)

    class(rectangle_class), intent(in) :: this

    a = this % width * this % height

end function rectangle_area

subroutine shape_print(this)

    class(shape_class), intent(in) :: this

    select type (this)
        type is (circle_class)
            write(*,'(A,F7.2,A,F8.3)') ' circle     r =', this % radius, &
                '   area =', this % area()
        type is (rectangle_class)
            write(*,'(A,F7.2,A,F8.3)') ' rectangle  w =', this % width, &
                '   area =', this % area()
        class default
            write(*,'(A,F8.3)') ' shape          area =', this % area()
    end select

end subroutine shape_print

subroutine describe(item)

    ! An unlimited polymorphic dummy argument accepts a value of any type.

    class(*), intent(in) :: item

    select type (item)
        type is (integer)
            write(*,*) 'an integer :', item
        type is (real)
            write(*,*) 'a real     :', item
        type is (character(len=*))
            write(*,*) 'a string   : ', item
        class is (shape_class)
            call item % print
        class default
            write(*,*) 'some other type'
    end select

end subroutine describe

end module shapes
