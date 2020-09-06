FC=gfortran
FFLAGS=-c
EXECUTABLE=myprog

$(EXECUTABLE): myprog.o mymodule.o
	$(FC) $^ -o $@

.f90.o:
	$(FC) $(FFLAGS) $< -o $@
	
clean:
	rm -rf *.o *.mod $(EXECUTABLE)

.SUFFIXES: .f90 .f03 .F .f
