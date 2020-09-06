program sample2

	implicit none
	real(8), allocatable :: infield(:,:)
	real(8), allocatable :: rowsum(:)
	integer :: rows, i, j
	
	!  File unit numbers
	
	integer, parameter :: infile = 15
	integer, parameter :: outfile = 16

	!  Allocate matrices

	rows=5
	allocate(infield(3,rows))
	allocate(rowsum(rows))

	!  Open the file 'indata.dat' for reading

	open(unit=infile,file='indata.dat',&
		access='sequential',&
		action='read')
		
	!  Open the file 'utdata.dat' for writing
		
	open(unit=outfile,file='utdata.dat',&
		access='sequential',&
		action='write')

	!  Read input from file

	do i=1,rows
		read(infile,*) (infield(j,i),j=1,3)
		rowsum(i)=&
			infield(1,i)+infield(2,i)+infield(3,i)
		write(outfile,*) rowsum(i)
	end do

	!  Close files

	close(infile)
	close(outfile)

	!  Free used memory

	deallocate(infield)
	deallocate(rowsum)
	
	stop
	
end program sample2