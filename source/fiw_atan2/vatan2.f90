
! Exported fortran subroutine vatan2.
! 
! Generated 2001-03-05 20:10:36
!  by Fortran interface wizard 1.0.1

subroutine vatan2(y,x,angle)

    ! ---- Subroutine export declarations.

    !dec\$attributes dllexport, stdcall :: vatan2

    !dec\$attributes value :: y
    !dec\$attributes value :: x
    !dec\$attributes reference :: angle

    ! ---- Declaration of exported variables.

    implicit none

    integer, parameter :: fp = selected_real_kind(15,300)

    real(fp) :: y
    real(fp) :: x
    real(fp) :: angle

    ! ---- Place other declarations below.

    angle = atan2(y,x)

    return

end subroutine vatan2
