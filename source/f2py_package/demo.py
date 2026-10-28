import numpy as np

import fmatrix

A = np.asfortranarray(np.arange(1.0, 7.0).reshape(2, 3))

print("norm =", fmatrix.fmatrix.frobenius_norm(A))

fmatrix.fmatrix.scale(A, 2.0)

print(A)
