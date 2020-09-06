module particles

    implicit none

    type particle_class
    private
        real :: m_pos(3)
        real :: m_vel(3)
    contains
        procedure :: init => particle_init
        procedure :: set_position => particle_set_position
        procedure :: set_velocity => particle_set_velocity
        procedure :: get_position => particle_get_position
        procedure :: get_velocity => particle_get_velocity
        procedure :: print => particle_print
        procedure :: x => particle_x
        procedure :: y => particle_y
        procedure :: z => particle_z
        procedure :: vx => particle_vx
        procedure :: vy => particle_vy
        procedure :: vz => particle_vz
        procedure, private :: particle_setup
    end type particle_class

    type, extends(particle_class) :: sphere_particle_class
    private
        real :: m_radius
    contains
        procedure :: init => sphere_init
        procedure :: set_radius => sphere_set_radius
        procedure :: radius => sphere_radius
        procedure :: print => sphere_print
    end type sphere_particle_class

contains

subroutine particle_init(this)

    class(particle_class) :: this

    this % m_pos = (/0.0, 0.0, 0.0/)
    this % m_vel = (/0.0, 0.0, 0.0/)

end subroutine particle_init

subroutine particle_set_position(this, x, y ,z)

    class(particle_class) :: this
    real, intent(in) :: x, y, z

    this % m_pos = (/x, y, z/)

end subroutine particle_set_position

subroutine particle_set_velocity(this, vx, vy ,vz)

    class(particle_class) :: this
    real, intent(in) :: vx, vy, vz

    this % m_vel = (/vx, vy, vz/)

end subroutine particle_set_velocity

subroutine particle_get_position(this, x, y ,z)

    class(particle_class) :: this
    real, intent(out) :: x, y, z

    x = this % m_pos(1)
    y = this % m_pos(2)
    z = this % m_pos(3)

end subroutine particle_get_position

subroutine particle_get_velocity(this, vx, vy ,vz)

    class(particle_class) :: this
    real, intent(out) :: vx, vy, vz

    vx = this % m_vel(1)
    vy = this % m_vel(2)
    vz = this % m_vel(3)

end subroutine particle_get_velocity


real function particle_x(this)

    class(particle_class) :: this

    particle_x = this % m_pos(1)

end function particle_x

real function particle_y(this)

    class(particle_class) :: this

    particle_y = this % m_pos(2)

end function particle_y

real function particle_z(this)

    class(particle_class) :: this

    particle_z = this % m_pos(3)

end function particle_z

real function particle_vx(this)

    class(particle_class) :: this

    particle_vx = this % m_vel(1)

end function particle_vx

real function particle_vy(this)

    class(particle_class) :: this

    particle_vy = this % m_vel(2)

end function particle_vy

real function particle_vz(this)

    class(particle_class) :: this

    particle_vz = this % m_vel(3)

end function particle_vz

subroutine particle_print(this)

    class(particle_class) :: this

    print*, 'Particle position'
    print*, '-----------------'
    write(*, '(3G10.3)') this % m_pos(1), this % m_pos(2), this % m_pos(3)

    print*, ''

    print*, 'Particle velocity'
    print*, '-----------------'
    write(*, '(3G10.3)') this % m_vel(1), this % m_vel(2), this % m_vel(3)

    print*, ''

end subroutine particle_print

subroutine particle_setup(this)

    class(particle_class) :: this

end subroutine particle_setup

subroutine sphere_init(this)

    class(sphere_particle_class) :: this

    call this % particle_class % init()

    this % m_radius = 1.0

end subroutine sphere_init

subroutine sphere_set_radius(this, r)

    class(sphere_particle_class) :: this
    real :: r

    this % m_radius = r

end subroutine sphere_set_radius

real function sphere_radius(this)

    class(sphere_particle_class) :: this

    sphere_radius = this % m_radius

end function sphere_radius

subroutine sphere_print(this)

    class(sphere_particle_class) :: this

    call this % particle_class % print

    print*, ''

    print*, 'Particle radius'
    print*, '-----------------'
    write(*, '(G10.3)') this % m_radius

    print*, ''

end subroutine sphere_print

end module particles
