program array1

    implicit none

    integer, parameter :: nElements = 20

    real :: A(nElements)
    integer :: i

    forall(i=1:nElements) A(i) = i * 2

    print*, A


end program array1
