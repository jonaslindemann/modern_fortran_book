! A[r,s] * B[s,t] = C[r,t]
subroutine matrix_multiply2(A,r,s,B,t,C)
	integer :: r, s, t
	real, intent(in) :: A(r,s)
	real, intent(in) :: B(s,t)
	real, intent(inout) :: C(r,t)

	C = matmul(A,B)
end subroutine matrix_multiply2
	
	