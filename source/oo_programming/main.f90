program oo_progrmming

    use particle_mod

    implicit none

    type(particle_sys_class) :: particle_sys

    call particle_sys % init(1000)

    call particle_sys % randomise_positions(0.0, 1.0, 0.0, 1.0)

    call particle_sys % print_positions()

    call particle_sys % destroy()
	
end program oo_progrmming
