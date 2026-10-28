import ctypes
from pathlib import Path

import numpy as np
from numpy.ctypeslib import load_library, ndpointer

lib = load_library("libvecops", Path(__file__).parent)

vector = ndpointer(dtype=np.float64, ndim=1, flags="C_CONTIGUOUS")
matrix = ndpointer(dtype=np.float64, ndim=2, flags="F_CONTIGUOUS")

lib.vec_dot.argtypes = [vector, vector, ctypes.c_int]
lib.vec_dot.restype = ctypes.c_double

lib.vec_axpy.argtypes = [ctypes.c_double, vector, vector, ctypes.c_int]
lib.vec_axpy.restype = None

lib.mat_mul.argtypes = [matrix, matrix, matrix,
                        ctypes.c_int, ctypes.c_int, ctypes.c_int]
lib.mat_mul.restype = None


def dot(x, y):
    return lib.vec_dot(x, y, x.size)


def axpy(a, x, y):
    lib.vec_axpy(a, x, y, x.size)


def mat_mul(a, b):
    m, k = a.shape
    n = b.shape[1]
    c = np.empty((m, n), order="F")
    lib.mat_mul(a, b, c, m, k, n)
    return c


if __name__ == "__main__":
    x = np.array([1.0, 2.0, 3.0])
    y = np.array([4.0, 5.0, 6.0])

    print("dot =", dot(x, y))

    axpy(2.0, x, y)
    print("y =", y)

    a = np.asfortranarray(np.arange(6.0).reshape(2, 3))
    b = np.asfortranarray(np.ones((3, 2)))
    print("a @ b =")
    print(mat_mul(a, b))
