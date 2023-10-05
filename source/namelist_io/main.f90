program namelist_io

    implicit none

    integer, parameter :: ir = 15
    integer, parameter :: iw = 16
    integer :: no_of_eggs, litres_of_milk, kilos_of_butter, list(5)
    namelist /food/ no_of_eggs, litres_of_milk, kilos_of_butter, list

    list = (/1, 2, 3, 4, 5 /)
    no_of_eggs = 1
    litres_of_milk = 2
    kilos_of_butter = 4


    open(unit=ir, file='food2.txt', status='unknown')
    read(ir, nml=food)
    print *, no_of_eggs, litres_of_milk, kilos_of_butter

    !read(ir, nml=food)
    !print *, no_of_eggs, litres_of_milk, kilos_of_butter
    !close(unit=ir)

    open(unit=iw, file='food2.txt', status='replace')
    write(iw, nml=food)
    close(unit=iw)

end program namelist_io
