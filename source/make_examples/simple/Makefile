myprog: myprog.o 
	gfortran myprog.o -o myprog

myprog.o: myprog.f90 
	gfortran -c myprog.f90

clean:
	rm *.o myprog