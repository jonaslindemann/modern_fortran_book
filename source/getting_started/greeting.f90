module greeting

    implicit none

    private

    public :: say_hello

contains

subroutine say_hello(name)

    character(len=*), intent(in) :: name

    write(*,*) 'Hello, '//trim(name)//'!'

end subroutine say_hello

end module greeting
