import sys
sys.path.append("./build") 

from numpy import *
from fortmod import *

print "-------------------------------------"
print simple.__doc__
print "-------------------------------------"
print

a = 2
b = 3
c = simple(a, b)

print "c =", c