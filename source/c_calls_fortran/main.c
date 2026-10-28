#include <stdio.h>

#include "stats.h"

int main(void)
{
    double x[5] = {1.0, 2.0, 3.0, 4.0, 5.0};

    printf("mean = %g\n", stats_mean(x, 5));

    stats_scale(x, 5, 10.0);

    printf("scaled =");
    for (int i = 0; i < 5; i++)
        printf(" %g", x[i]);
    printf("\n");

    double a[3][4] = {
        {1.0, 2.0, 3.0, 4.0},
        {5.0, 6.0, 7.0, 8.0},
        {9.0, 10.0, 11.0, 12.0}
    };
    double sums[3];

    stats_row_sums(&a[0][0], 3, 4, sums);

    printf("row sums = %g %g %g\n", sums[0], sums[1], sums[2]);

    return 0;
}
