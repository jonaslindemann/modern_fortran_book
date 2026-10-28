import numpy as np

import fortmod

A = np.full((6, 6), 10.0, order="F")
B = np.full((6, 6), 20.0, order="F")
C = np.zeros((6, 6), order="F")

print("id of C before multiply =", id(C))

C = fortmod.matrix.matrix_multiply(A, B)

print("id of C after multiply  =", id(C))
print(C)
