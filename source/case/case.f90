program case_sample

    integer :: value

    write(*,*) 'Enter a value'
    read(*,*) value

    select case (value)
        case (:0)
            write(*,*) 'Greater than one.'
        case (1)
            write(*,*) 'Number one!'
        case (2:9)
            write(*,*) 'Between 2 and 9.'
        case (10)
            write(*,*) 'Number 10!'
        case (11:41)
            write(*,*) 'Less than 42 but greater than 10.'
        case (42)
            write(*,*) 'Meaning of life or perhaps 6*7.'
        case (43:)
            write(*,*) 'Greater than 42.'
        case default
            write(*,*) 'This should never happen!'
    end select

    stop

end program case_sample
