program unformatted_io_2

    implicit none

    ! ---- Define some program constants

    integer, parameter :: iw = 15
    integer, parameter :: ir = 16
    integer, parameter :: nParticles = 1000

    ! ---- Define particle data type

    type particle
        real :: position(3)
        real :: velocity(3)
        real :: mass
    end type particle

    ! ---- Program variables

    integer :: i

    ! ---- Allocatable array of particles

    type(particle), allocatable :: particles(:)

    allocate(particles(nParticles))

    ! ---- Initialise particle array

    do i=1,nParticles
        particles(i)%position = 0.0
        particles(i)%velocity = 0.0
        particles(i)%mass = 1.0
    end do

    ! ---- Write all particles to disk

    open(unit=iw, file='particles.dat', form='unformatted', status='replace')
    write(unit=iw) particles
    close(unit=iw)

    ! ---- Deallocate particles array

    deallocate(particles)

    ! ---- Allocate new array and read back data from disk

    allocate(particles(nParticles))

    open(unit=ir, file='particles.dat', form='unformatted')
    read(unit=ir) particles
    close(unit=ir)

    ! ---- Print contents of array

    print*, particles

    ! ---- Deallocate array

    deallocate(particles)


end program unformatted_io_2
