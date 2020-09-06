module mytype_module

    type mytype
        real :: myvalue(4) = 0.0
    contains
        procedure :: write => write_mytype
        procedure :: reset
    end type mytype

    private :: write_mytype, reset

contains

    subroutine write_mytype(this, unit)
        class(mytype) :: this
        integer, optional :: unit
        if (present(unit)) then
            write(unit,*) this%myvalue
        else
            print *, this%myvalue
        end if
    end subroutine write_mytype

    subroutine reset(variable)
        class(mytype) :: variable
        variable%myvalue = 0.0
    end subroutine reset

end module mytype_module
