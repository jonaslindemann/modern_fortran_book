module mymodule

    implicit none

    integer, public :: visible
    integer, private :: invisible

    private privatefunc
    public publicfunc

contains

subroutine privatefunc

    print *, 'This function can only be called from within a module.'

end subroutine privatefunc

subroutine publicfunc

    call privatefunc

end subroutine publicfunc

end module mymodule
