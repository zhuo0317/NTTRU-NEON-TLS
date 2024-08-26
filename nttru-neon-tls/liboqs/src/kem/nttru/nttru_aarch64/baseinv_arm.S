/* ARMv8 implementation of BASEMUL function */
/* Called in POLY.C (See void poly_basemul_montgomery(poly *r, const poly *a, const poly *b)) */
/* New version (v2) */

.include "macros.inc"

/*************************************************
*	Macro Name:		baseinv
*	Description:	polynomial inverse in Zq[X]/(X^3-zeta)
*	Arguments:		va0.8h = ai, va1.8h = ai, vb0.8h = bi, vb1.8h = bi, v0.8h = zetas, v31.8h[0] = r, {v19.8h, v15.8h[0,1]}=constants
*	Intermediate Values/Vectors: v3, v4, v5, v16, v17, v18, v20, v21-v28, v30
*					- It requires to construct vz vector from zetas
**************************************************/
.macro baseinv a, b, c, d, zeta
	fqmul   3, \a, \a  //v3=a0a0
	fqmul   4, \c, \c  //v4=a2a2
	fqmul   5, \b, \b  //v5=a1a1

	fqmul   16, \b, \c //a1*a2
	fqmul   16, 16, \zeta //a1*a2*zeta
	sub     v16.8h, v3.8h, v16.8h //a0a0-a1a2zeta  b0

	fqmul   4, 4, \zeta //a2a2*zeta
	fqmul   17, \a, \b //a0*a1
	sub     v17.8h, v4.8h, v17.8h //a2a2zeta-a0a1

	fqmul   18, \a, \c //a0a2
	sub     v18.8h, v5.8h, v18.8h //a1a1-a0a2

	fqmul   \d, 18, \b //b2*a1
	fqmul   20, 17, \c //b1*a2
	add     v\d\().8h, v\d\().8h, v20.8h //b2a1+b1a2
	fqmul   \d, \d, \zeta
	fqmul   20, 16, \a //b0*a0
	add     v\d\().8h, v\d\().8h, v20.8h //(b2a1+b1a2)*zeta+b0a0
	fqinv   \d
	fqmul   \a, 16, \d //b0*det
	fqmul   \b, 17, \d //b1*det
	fqmul   \c, 18, \d //b2*det
	cmeq    v\d\().8h, v\d\().8h, v19.8h

.endm


//iteration
.macro baseinv4
    ld1   {v6.8h-v8.8h}, [x2], #48	    // after: x0 at r24
	ld1   {v9.8h-v11.8h}, [x2], #48	    // after: x0 at r48
	/*shuffle4 6, 7, 8 ,9, 10, 11
	shuffle2 6, 7, 8 ,9, 10, 11
	shuffle1 6, 7, 8 ,9, 10, 11*/
	ld1r   {v19.8h}, [x0], #2
	sub x0, x0, #2
	ld1    {v0.8h}, [x3], #16//zeta
	baseinv 6, 9, 7, 12, 0
	ld1    {v0.8h}, [x3], #16//zeta
	baseinv 10, 8, 11, 13, 0
	/*shuffle1 6, 10, 8 ,9, 7, 11
	shuffle2 6, 7, 9 ,8, 10, 11
	shuffle4 6, 7, 8 ,9, 10, 11*/
	st1   {v6.8h-v8.8h}, [x1], #48
	st1   {v9.8h-v11.8h}, [x1], #48
.endm

.global NTTRU_AARCH64_baseinv_arm
NTTRU_AARCH64_baseinv_arm:
    mov		w4, 7681
  	mov		v15.h[0], w4		// v15.s[0] = q = 7681
  	mov		w4, 57857
    mov		v15.h[1], w4 		// v15.s[1] = qinv = 57857     q^(-1) mod 2^16
	baseinv4
	add    V21.8H,V12.8H,V13.8H
	baseinv4
	add    V22.8H,V12.8H,V13.8H
	baseinv4
	add    V23.8H,V12.8H,V13.8H
	baseinv4
	add    V24.8H,V12.8H,V13.8H
	baseinv4
	add    V25.8H,V12.8H,V13.8H
	baseinv4
	add    V26.8H,V12.8H,V13.8H
	baseinv4
	add    V27.8H,V12.8H,V13.8H
	baseinv4
	add    v28.8H,V12.8H,V13.8H
	addxor 21, 22, 23, 24, 25, 26, 27, 28, 30
	baseinv4
	add    V21.8H,V12.8H,V13.8H
	baseinv4
	add    V22.8H,V12.8H,V13.8H
	baseinv4
	add    V23.8H,V12.8H,V13.8H
	baseinv4
	add    V24.8H,V12.8H,V13.8H
	baseinv4
	add    V25.8H,V12.8H,V13.8H
	baseinv4
	add    V26.8H,V12.8H,V13.8H
	baseinv4
	add    V27.8H,V12.8H,V13.8H
	baseinv4
	add    v28.8H,V12.8H,V13.8H
	addxor 21, 22, 23, 24, 25, 26, 27, 28, 31
	add    v31.8H,V30.8H,V31.8H
	trn2   v30.2d, v31.2d, v30.2d
	add    v31.8H,V30.8H,V31.8H
	trn2   v30.4s, v31.4s, v30.4s
	add    v31.8H,V30.8H,V31.8H
	trn2   v30.8h, v31.8h, v30.8h
	add    v31.8H,V30.8H,V31.8H
	st1    {v31.8h}, [x0], #16
    ret
