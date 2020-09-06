! ------------------------------------------------------------------
!
!       Hjälprutiner för beräkning av en kontinuerlig balk
!
!       Copyright (c) 2000 Division of Structural Mechanics
!
! ------------------------------------------------------------------
!
! Skriven av Jonas Lindemann, Ola Dahlblom

module beam

	! Precision på flyttal

	integer, parameter :: ap = selected_real_kind(15,300)
	
contains

! ------------------------------------------------------------------

subroutine beam2e(L,q,E,A,I,Ke,fe)

	! Skapar elementstyvhetsmatris och last vektor för
	! ett balkelement

	implicit none

	real(ap), intent(in) :: L, q, E, A, I
	real(ap), intent(out) :: Ke(4,4)
	real(ap), intent(out) :: fe(4)

	Ke(1,:) = (/  12.0_ap*E*I/L**3,  6.0_ap*E*I/L**2, &
	             -12.0_ap*E*I/L**3,  6.0_ap*E*I/L**2 /)
	Ke(2,:) = (/   6.0_ap*E*I/L**2,  4.0_ap*E*I/L   , &
	              -6.0_ap*E*I/L**2,  2.0_ap*E*I/L /)
	Ke(3,:) = (/ -12.0_ap*E*I/L**3, -6.0_ap*E*I/L**2, &
	              12.0_ap*E*I/L**3, -6.0_ap*E*I/L**2 /)
	Ke(4,:) = (/   6.0_ap*E*I/L**2,  2.0_ap*E*I/L   , &
	              -6.0_ap*E*I/L**2,  4.0_ap*E*I/L    /)

	fe(1) =  q*L/2.0_ap
	fe(2) =  q*L**2/12.0_ap
	fe(3) =  q*L/2.0_ap
	fe(4) = -q*L**2/12.0_ap

	return 

end subroutine beam2e

! ------------------------------------------------------------------

subroutine beam2s(L,q,E,A,I,Ed,np,ShearForces,Moments,Deflections)

	! Beräknar deformationer och snittkrafter
	! för ett beräknat balkelement

	implicit none

	real(ap), intent(in) :: L, q, E, A, I
	real(ap), intent(in) :: Ed(4,1)
	integer, intent(in) :: np
	real(ap), intent(out) :: ShearForces(np)
	real(ap), intent(out) :: Moments(np)
	real(ap), intent(out) :: Deflections(np)
	
	integer :: j

	real(ap) :: N(1,4)
	real(ap) :: dN1(1,4)
	real(ap) :: dN2(1,4)
	real(ap) :: dN3(1,4)

	real(ap) :: invC(4,4)
	real(ap) :: scalar(1,1)
	real(ap) :: dx, x
	real(ap) :: uh, up
	real(ap) :: duh1, duh2, duh3
	real(ap) :: dup1, dup2, dup3

	dx = L/(np-1.0_ap)

    invC(1,:) = (/ 1.0_ap, 0.0_ap, 0.0_ap, 0.0_ap /)
	invC(2,:) = (/ 0.0_ap, 1.0_ap, 0.0_ap, 0.0_ap /)
	invC(3,:) = (/ -3.0_ap/L**2, -2.0_ap/L, 3.0_ap/L**2, -1.0_ap/L /)
	invC(4,:) = (/ 2.0_ap/L**3, 1.0_ap/L**2, -2/L**3, 1/L**2 /)

    do j=1,np
		x = (j-1)*dx

        N(1,:) = (/ 1.0_ap, x, x**2, x**3 /)
		dN1(1,:) = (/ 0.0_ap, 1.0_ap, 2.0_ap*x, 3.0_ap*x**2 /)
		dN2(1,:) = (/ 0.0_ap, 0.0_ap, 2.0_ap, 6.0_ap*x /)
		dN3(1,:) = (/ 0.0_ap, 0.0_ap, 0.0_ap, 6.0_ap /)
		
		scalar = matmul(matmul(N,invC),Ed)
		uh = scalar(1,1)
		scalar = matmul(matmul(dN2,invC),Ed)
		duh2 = scalar(1,1)
		scalar = matmul(matmul(dN3,invC),Ed)
		duh3 = scalar(1,1)

		up = q*L**2*x**2*(1-x/L)**2/24.0_ap/E/I
		dup2 = q*L**2*(2.0_ap-12.0_ap*x/L + 12.0_ap*x**2/L**2)/24.0_ap/E/I
		dup3 = q*L**2*(24.0_ap*x/L**2-12.0_ap/L)/24.0_ap/E/I
		
		ShearForces(j) = -E*I*(duh3 + dup3)
		Moments(j) = E*I*(duh2 + dup2)
		Deflections(j) = uh + up

	end do

	return
		
end subroutine beam2s 

! ------------------------------------------------------------------

subroutine assemElementLoad(edof,K,Ke,f,fe)

	! Assemblerar in en elementstyvhetsmatris i 
	! Den globala styvhetsmatrisen

	implicit none

	integer  :: nDof
	integer  :: edof(:)
	real(ap) :: K(:,:)
	real(ap) :: Ke(:,:)
	real(ap) :: f(:),fe(:)

	integer :: i,j

	nDof = size(edof)

	K(edof(1:nDof),edof(1:nDof)) = &
		K(edof(1:nDof),edof(1:nDof)) + Ke

	f(edof(1:nDof)) = f(edof(1:nDof)) + fe

	return

end subroutine assemElementLoad

! ------------------------------------------------------------------

subroutine solveq(K,f,bcPrescr,bcValue,a,Q)

	! Hjälprutin för att anpassa parametrarna till 
	! solve till CALFEM konventioner

	implicit none

	real(ap) :: K(:,:)
	real(ap) :: f(:)
	integer  :: bcPrescr(:)
	real(ap) :: bcValue(:)
	real(ap) :: a(*)
	real(ap) :: Q(*)

	real(ap), allocatable :: fTemp(:)

	integer :: dimK(2)
	integer :: i, ierr

	! Bestäm storlek på ekvationssystem

	dimK = shape(K)

	! Skapa en temporär f-vektor, för att solve inte skall
	! ändra den befintliga f-vektorn.

	allocate(fTemp(dimK(1)))

	fTemp = f

	! Tilldela föreskrivna förskjutningar till global 
	! förskjutningsvektor

	do i=1,dimK(1)
		if (bcPrescr(i).EQ.1) then
			a(i) = bcValue(i)
		end if
	end do

	! Lös systemet

	call solve(K,a,f,Q,bcPrescr,dimK(1),ierr)

	! Städa upp

	deallocate(fTemp)

	return

end subroutine solveq

! ------------------------------------------------------------------

subroutine solve(s,u,r,q,ipv,neq,ierr)

	! syfte
	!	 lösning av ekvationssystem
	!
	! beskrivning av parametrar
	!	 s(neq,neq) 	systemmatris
	!	 u(neq) 		nodvariabelvektor
	!	 r(neq) 		lastvektor
	!	 q(neq) 		reaktionsvektor
	!	 ipv(neq)		anger föreskriven (=1) eller fri variabel (=0)
	!	 neq			antal frihetsgrader
	!
	! referenser
	!	 skriven: ola dahlblom 1985-03-11
	!	 reviderad: ola dahlblom 1994-03-29

	implicit none

	integer, parameter :: ap=selected_real_kind(15,300)
	integer :: ierr,neq,ieq,jeq,keq
	real(ap) :: c1,c2
	real(ap), parameter :: small=10.0_ap*tiny(c1)
	real(ap), dimension(neq) :: r,u,q
	real(ap), dimension(neq,neq) :: s
	integer, dimension(neq) :: ipv

	! modifiering av lastvektor

	do ieq=1,neq
		if(ipv(ieq).eq.0) then
			do jeq=1,neq
				if(ipv(jeq).eq.1) then
					r(ieq)=r(ieq)-s(ieq,jeq)*u(jeq)
				endif
			end do
		endif
	end do

	! triangulering

	do ieq=1,neq-1
		if(ipv(ieq).eq.0) then
			c1=s(ieq,ieq)
			if(abs(c1).lt.1.0d-50) then
				ierr=1
				return
			end if
			do keq=ieq+1,neq
				if(ipv(keq).eq.0) then
					c2=s(keq,ieq)/c1
					do jeq=ieq,neq
						if(ipv(jeq).eq.0) then
							s(keq,jeq)=s(keq,jeq)-c2*s(ieq,jeq)
						endif
					end do
					r(keq)=r(keq)-c2*r(ieq)
				endif
			end do
		endif
	end do

	! bakåtsubstitution

	do ieq=neq,1,-1
		if(ipv(ieq).eq.0) then
			u(ieq)=r(ieq)
			do jeq=ieq+1,neq
				if(ipv(jeq).eq.0) then
					u(ieq)=u(ieq)-s(ieq,jeq)*u(jeq)
				endif
			end do
			u(ieq)=u(ieq)/s(ieq,ieq)
		endif
	end do

	! reaktioner

	do ieq=1,neq
		if(ipv(ieq).eq.1) then
			q(ieq)=-r(ieq)
			do jeq=1,neq
				q(ieq)=q(ieq)+s(ieq,jeq)*u(jeq)
			end do
		else
			q(ieq)=0.0_ap
		end if
	end do

	return

end subroutine solve

! ------------------------------------------------------------------
! ------------------------------------------------------------------

end module beam