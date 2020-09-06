module particle_mod

    type particle_sys_class
        integer :: nParticles
        real, allocatable :: pos(:,:)
        real, allocatable :: vel(:,:)
    contains
        procedure :: init
        procedure :: destroy
        procedure :: print_positions
        procedure :: print_velocities
        procedure :: update
        procedure :: randomise_positions
    end type particle_sys_class

contains

subroutine init(this, n)

    class(particle_sys_class) :: this
    this % nParticles = n

    allocate(this % pos(n,3), this % vel(n,3))

end subroutine init

subroutine print_positions(this)

    class(particle_sys_class) :: this
    integer :: i

    write(*, '(A10,A10,A10)') 'x(m)', 'y(m)', 'z(m)'
    write(*, '(A30)') '------------------------------'

    do i=1,this % nParticles
        write(*, '(3G10.3)') this % pos(i,1), this % pos(i,2), this % pos(i,3)
    end do

end subroutine print_positions

subroutine print_velocities(this)

    class(particle_sys_class) :: this
    integer :: i

    write(*, '(A10,A10,A10)') 'vx(m)', 'vy(m)', 'vz(m)'
    write(*, '(A30)') '------------------------------'

    do i=1,this % nParticles
        write(*, '(3G10.3)') this % vel(i,1), this % vel(i,2), this % vel(i,3)
    end do

end subroutine print_velocities

subroutine randomise_positions(this, minX, maxX, minY, maxY)

    class(particle_sys_class) :: this
    real :: minX, maxX, minY, maxY

    call random_number(this % pos)
    call random_number(this % vel)

end subroutine randomise_positions


subroutine update(this, dt)

    class(particle_sys_class) :: this
    real :: dt

    this % pos = this % pos + this % vel * dt

end subroutine update

subroutine destroy(this)

    class(particle_sys_class) :: this

    deallocate(this % pos, this % vel)

end subroutine destroy

end module particle_mod
