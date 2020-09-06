FC=gfortran
FFLAGS=-c
EXECUTABLE=myprog

$(EXECUTABLE): myprog.o mymodule.o
	$(FC) $^ -o $@

myprog.o: myprog.f90 
	$(FC) $(FFLAGS) $< -o $@

mymodule.o: mymodule.f90
	$(FC) $(FFLAGS) $< -o $@
	
clean:
	rm -rf *.o *.mod $(EXECUTABLE)

