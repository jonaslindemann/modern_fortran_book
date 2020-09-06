! ------------------------------------------------------------------
!
!       Beräkningsrutin för kontinuerlig balk
!
!       Copyright (c) 2000 Division of Structural Mechanics
!
! ------------------------------------------------------------------
!
! Skriven av Jonas Lindemann

subroutine calc(nBeams, nMaterials, BeamLengths, BeamLoads, BeamProps, &
                BCTypes, BCDisplValues, BCRotValues, Materials, &
				Displacement, Reaction, &
				EvaluationPoints, ShearForces,Moments,Deflections)

	!dec\$attributes dllexport, stdcall :: calc
	
	!dec\$attributes value     :: nBeams, nMaterials
	!dec\$attributes reference :: BeamLengths, BeamLoads, BeamProps
	!dec\$attributes reference :: BCTypes, BCDisplValues, BCRotValues, Materials
	!dec\$attributes reference :: Displacement, Reaction
	!dec\$attributes value     :: EvaluationPoints
	!dec\$attributes reference :: ShearForces,Moments,Deflections

	use beam

	implicit none

	! --- Anropsvariabler

	integer(4) :: nBeams, nMaterials
	real(8) :: BeamLengths(*)
	real(8) :: BeamLoads(*)
	integer(4) :: BeamProps(*)
	integer(4) :: BCTypes(*)
	real(8) :: BCDisplValues(*)
	real(8) :: BCRotValues(*)
	real(8) :: Materials(3,*)
	real(8) :: Reaction(*)
	real(8) :: Displacement(*)
	integer(4) :: EvaluationPoints
	real(8) :: Moments(EvaluationPoints,*)
	real(8) :: ShearForces(EvaluationPoints,*)
	real(8) :: Deflections(EvaluationPoints,*)

	! --- Lokala variabler

	integer, parameter    :: outfile = 15
	integer               :: i, j

	integer, allocatable  :: Edof(:,:)
	integer               :: DofCount
	integer               :: DofsNeeded
	real(ap), allocatable :: K(:,:)
	real(ap), allocatable :: f(:)
	real(ap)              :: Ke(4,4)
	real(ap)              :: fe(4)
	real(ap)              :: E, Area, It, L, q
	real(ap), allocatable :: bcValue(:)
	integer, allocatable  :: bcPrescr(:)
	real(ap)              :: Ed(4)

	! --- Skapa Edof matris

	allocate(Edof(nBeams,4))
	DofsNeeded = (nBeams+1)*2
	DofCount = 1

	do i=1,nBeams
		Edof(i,:) = (/ DofCount, DofCount+1, DofCount+2, DofCount+3 /)
		DofCount = DofCount + 2
	end do

	! --- Skapa global styvhetsmatris och lastvektor

	allocate(K(DofsNeeded,DofsNeeded))
	allocate(f(DofsNeeded))

	! --- Assemblera ihop styvhetsmatris

	do i=1,nBeams
	    L = BeamLengths(i)
		q = BeamLoads(i)
		E = Materials(1,BeamProps(i))
		Area = Materials(2,BeamProps(i))
		It = Materials(3,BeamProps(i))
		call beam2e(L, q, E, Area, It, Ke, fe) 
		call assemElementLoad(Edof(i,:),K,Ke,f,fe)
	end do

	! --- Definiera randvillkor

	DofCount = 1

	allocate(bcPrescr(DofsNeeded))
	allocate(bcValue(DofsNeeded))

	bcPrescr = 0
	bcValue = 0.0_ap

	do i=1,nBeams+1
		if (BCTypes(i)/=0) then
			if (BCTypes(i)==1) then
				bcPrescr(DofCount + 1) = 1
				bcValue(DofCount + 1) = BCRotValues(i)
			end if
			if (BCTypes(i)==2) then
				bcPrescr(DofCount) = 1
				bcValue(DofCount) = BCDisplValues(i)
			end if
			if (BCTypes(i)==3) then
				bcPrescr(DofCount + 1) = 1
				bcValue(DofCount + 1) = BCRotValues(i)
				bcPrescr(DofCount) = 1
				bcValue(DofCount) = BCDisplValues(i)
			end if
		end if
		DofCount = DofCount + 2
	end do

	! --- Lös ekvationssystem

	call solveq(K,f,bcPrescr,bcValue,Displacement,Reaction)

	! --- Beräkna elementkrafter

	do i=1,nBeams
		Ed = Displacement(Edof(i,:))
	    L = BeamLengths(i)
		q = BeamLoads(i)
		E = Materials(1,BeamProps(i))
		Area = Materials(2,BeamProps(i))
		It = Materials(3,BeamProps(i))
		call beam2s(L, q, E, Area, It, Ed, EvaluationPoints, &
		  ShearForces(:,i),Moments(:,i),Deflections(:,i))
	end do

	! --- Städa 

	deallocate(K)
	deallocate(f)
	deallocate(Edof)
	deallocate(bcPrescr)
	deallocate(bcValue);

	return

end subroutine calc