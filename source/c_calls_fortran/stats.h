#ifndef STATS_H
#define STATS_H

double stats_mean(const double *x, int n);
void stats_scale(double *x, int n, double factor);
void stats_row_sums(const double *a, int rows, int cols, double *sums);

#endif
