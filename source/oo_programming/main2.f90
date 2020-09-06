program oo_progrmming

    use particles

    implicit none

    integer, parameter :: nParticles = 100

    integer :: i
    real :: pos(3)
    real :: vel(3)
    real :: x, y, z

    type(particle_class) :: particle
    type(sphere_particle_class) :: sphere_particle
    type(particle_class), allocatable :: partArray(:)

    !particle % pos(1) = 0.0 ! Will produce an error.

    call particle % init
    call particle % set_position(1.0, 1.0, 1.0)
    call particle % set_velocity(1.0, 1.0, 1.0)
    call particle % get_position(x, y, z)
    call particle % print

    call sphere_particle % init
    call sphere_particle % set_position(1.0, 1.0, 1.0)
    call sphere_particle % set_velocity(1.0, 1.0, 1.0)
    call sphere_particle % get_position(x, y, z)
    call sphere_particle % print


    allocate(partArray(nParticles))

    do i=1,nParticles
        call random_number(pos)
        call random_number(vel)
        call partArray(i) % init
        call partArray(i) % set_position(pos(1), pos(2), pos(3))
        call partArray(i) % set_velocity(vel(1), vel(2), vel(3))
    end do

end program oo_progrmming
