FC = gfortran
FFLAGS = -c
EXECUTABLE = myprog

F90_FILES := $(wildcard *.f90)
OBJECTS := $(patsubst %.f90, %.o, $(F90_FILES))

$(EXECUTABLE): $(OBJECTS) $(MODFILES)
	$(FC) $^ -o $@
	
mymodule.o: myutils.o

%.o %.mod: %.f90
	$(FC) $(FFLAGS) $< -o $@
	
clean:
	rm -rf *.o *.mod $(EXECUTABLE)

.SUFFIXES: .f90
