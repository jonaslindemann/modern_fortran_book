myprog: myprog.o mymodule.o
	gfortran myprog.o mymodule.o -o myprog

myprog.o: myprog.f90 
	gfortran -c myprog.f90

mymodule.o: mymodule.f90
	gfortran -c mymodule.f90

clean:
	rm *.o *.mod myprog