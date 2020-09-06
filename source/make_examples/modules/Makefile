myprog: module_main.o module_truss.o
	gfortran module_main.o module_truss.o -o myprog

module_main.o: module_main.f90 module_truss.o
	gfortran -c module_main.f90

module_truss.o: module_truss.f90
	gfortran -c module_truss.f90

clean:
	rm *.o *.mod myprog
