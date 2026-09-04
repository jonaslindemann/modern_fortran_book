module temperatures

    use iso_fortran_env, only: real64

    implicit none

    private

    public :: to_kelvin, clamp

contains

pure real(real64) function to_kelvin(celsius) result(kelvin)

    real(real64), intent(in) :: celsius

    kelvin = celsius + 273.15_real64

end function to_kelvin

elemental real(real64) function clamp(x, lo, hi) result(y)

    real(real64), intent(in) :: x, lo, hi

    y = min(max(x, lo), hi)

end function clamp

end module temperatures
