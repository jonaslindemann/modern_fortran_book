import sys
sys.path.append("./build") 

from numpy import *
from fortmod import *

print "-------------------------------------"
print matrix_multiply.__doc__
print "-------------------------------------"
print

A = ones((6,6), 'f', order='F') * 10.0
B = ones((6,6), 'f', order='F') * 20.0
C = zeros((6,6), 'f', order='F')

print "id of C before multiply =",id(C)

C = matrix_multiply(A, B)

print "id of C after multiply =",id(C)

print C