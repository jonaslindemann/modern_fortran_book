submodule (points) points_a

contains

real module function point_dist(a,b)
    type(point), intent(in) :: a, b
    point_dist = sqrt((a%x-b%x)**2+(a%y-b%y)**2)
end function point_dist

end submodule points_a
