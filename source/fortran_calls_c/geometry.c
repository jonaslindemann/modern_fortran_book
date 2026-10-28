#include <math.h>
#include <stdio.h>

typedef struct {
    double x;
    double y;
} point;

double distance(point a, point b)
{
    return hypot(b.x - a.x, b.y - a.y);
}

void translate(point *p, int n, double dx, double dy)
{
    for (int i = 0; i < n; i++) {
        p[i].x += dx;
        p[i].y += dy;
    }
}

void greet(const char *name)
{
    printf("Hello, %s, from C!\n", name);
}
