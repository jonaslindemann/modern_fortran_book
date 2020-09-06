FC=gfortran
FFLAGS=-c
EXECUTABLE=myprog

$(EXECUTABLE): myprog.o mymodule.o
	$(FC) myprog.o mymodule.o -o myprog

myprog.o: myprog.f90 
	$(FC) $(FFLAGS) myprog.f90

mymodule.o: mymodule.f90
	$(FC) $(FFLAGS) mymodule.f90
	
clean:
	rm -rf *.o *.mod $(EXECUTABLE)

