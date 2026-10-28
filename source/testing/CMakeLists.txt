add_executable(check_stats stats.f90 check_stats.f90)

add_test(NAME check_stats COMMAND check_stats)
