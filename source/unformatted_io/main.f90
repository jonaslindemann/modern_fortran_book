program unformatted_io

    implicit none

    integer, parameter :: iw = 15
    type account
    character(len=40) :: account_holder
    real :: balance
    end type account

    type(account) :: accountA
    type(account) :: accountB
    integer :: recordSize

    inquire(iolength=recordSize) accountA

    print *, 'Record size =',recordSize

    accountA%account_holder = 'Olle'
    accountA%balance = 400

    accountB%account_holder = 'Janne'
    accountB%balance = 800

    open(unit=iw, file='bank.dat', access='direct', recl=recordSize, status='replace')
    write(iw, rec=1) accountA
    write(iw, rec=2) accountB
    close(unit=iw)

end program unformatted_io
