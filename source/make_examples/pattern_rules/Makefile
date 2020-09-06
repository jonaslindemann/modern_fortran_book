FC=gfortran
FFLAGS=-c
EXECUTABLE=myprog

F90_FILES := $(wildcard *.f90)
OBJECTS := $(patsubst %.f90, %.o, $(F90_FILES))

$(EXECUTABLE): $(OBJECTS)	
	$(FC) $^ -o $@

%.o: %.f90
	$(FC) $(FFLAGS) $< -o $@
	
clean:
	rm -rf *.o *.mod $(EXECUTABLE)
