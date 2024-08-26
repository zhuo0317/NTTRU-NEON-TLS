/* ARMv8 implementation of BASEMUL function */
/* Called in POLY.C (See void poly_basemul_montgomery(poly *r, const poly *a, const poly *b)) */
/* New version (v2) */

.include "macros.inc"

/*************************************************
*	Macro Name:		basemul
*	Description:	(Core part)
*					Multiplication of polynomials in Zq[X]/(X^2-zeta)
*					i.e. (c0 + c1 X)  = (a0 + a1 X)*(b0 * b1 X) mod (X^2-zeta)
*	Arguments:		(Core part)
*					va0.8h = [a00, a01, ..., a07],
*					va1.8h = [a10, a11, ..., a17],
*					vb0.8h = [b00, b01, ..., b07],
*					vb1.8h = [b10, b11, ..., b17],
*					vz.8h = [z0, −z0, ..., z3, −z3],
*					vc0.8h = [c00, c01, ..., c07],
*					vc1.8h = [c10, c11, ..., c17]
*	Intermediate Values/Vectors: v0, v9, v10, v11, v16, v17, v18, v19, v20, v21, v22
*	Notes:			- It requires pre- and post- operations to re-order
*					because the polynomial in NTT domain is originally ordered as
*					a0, a1 -> a0 + a1 * X
*					- It requires to construct vz vector from zetas
**************************************************/
.macro basemul a, b, c, d, e, f, zeta //点乘 karatsuba
	fqmul   3, \a, \d  //v3=f0g0
	fqmul   4, \b, \e  //v4=f1g1
	fqmul   5, \c, \f  //v5=f2g2

	add     v23.8h, v\a\().8h, v\b\().8h  //v13=f0+f1
	add     v26.8h, v\d\().8h, v\e\().8h  //v18=g0+g1
	add     v24.8h, v\a\().8h, v\c\().8h  //v16=f0+f2
	add     v27.8h, v\d\().8h, v\f\().8h  //v19=g0+g2
	add     v22.8h, v\b\().8h, v\c\().8h  //v12=f1+f2
	add     v25.8h, v\e\().8h, v\f\().8h  //v17=g1+g2

    fqmul   \a, 25, 22 //(f1+f2)*(g1+g2)
	sub     v\a\().8h, v\a\().8h, v4.8h //(f1+f2)*(g1+g2)-f1g1
	sub     v\a\().8h, v\a\().8h, v5.8h //(f1+f2)*(g1+g2)-f1g1-f2g2
	fqmul   \a, \a, \zeta
	add     v\a\().8h, v\a\().8h, v3.8h //((f1+f2)*(g1+g2)-f1g1-f2g2)*w+f0g0

	fqmul   \b, 26, 23 //(f0+f1)*(g0+g1)
	sub     v\b\().8h, v\b\().8h, v3.8h //(f0+f1)*(g0+g1)-f0g0
	sub     v\b\().8h, v\b\().8h, v4.8h //(f0+f1)*(g0+g1)-f0g0-f1g1
	fqmul   23, 5, \zeta
	add     v\b\().8h, v\b\().8h, v23.8h //vb=(f0+f1)*(g0+g1)-f0g0-f1g1+f2g2*w

	fqmul   \c, 27, 24 //(f0+f2)*(g0+g2)
	sub     v\c\().8h, v\c\().8h, v3.8h //(f0+f2)*(g0+g2)-f0g0
	sub     v\c\().8h, v\c\().8h, v5.8h //(f0+f2)*(g0+g2)-f0g0-f2g2
	add     v\c\().8h, v\c\().8h, v4.8h //(f0+f2)*(g0+g2)-f0g0-f2g2+f1g1
.endm

//迭代
.macro basemul4
    ld1   {v6.8h-v8.8h}, [x1], #48	    // after: x0 at r24
	ld1   {v9.8h-v11.8h}, [x1], #48	    // after: x0 at r48
	ld1   {v16.8h-v18.8h}, [x2], #48	// after: x1 at r24
	ld1   {v19.8h-v21.8h}, [x2], #48	// after: x1 at r48
	/*shuffle4 6, 7, 8, 9, 10, 11
	shuffle4 16, 17, 18, 19, 20, 21
	shuffle2 6, 7, 8, 9, 10, 11
	shuffle2 16, 17, 18, 19, 20, 21
	shuffle1 6, 7, 8, 9, 10, 11
	shuffle1 16, 17, 18, 19, 20, 21*/
	ld1     {v0.8h}, [x3], #16
	sswitch 8, 9
	sswitch 18, 19
	basemul 6, 8, 7, 16, 18, 17, 0
	ld1     {v0.8h}, [x3], #16
	basemul 10, 9, 11, 20, 19, 21, 0
	sswitch 8, 9
	
	st1   {v6.8h-v8.8h}, [x0], #48
	st1   {v9.8h-v11.8h}, [x0], #48
.endm



/*************************************************
*	Function Name:	basemul_arm
*	Description:	Pointwise multiplication of polynomials
*	Corresponds to:	void basemul_arm(int16_t *poly, const int16_t *a, const int16_t *b, const int16_t* zetas);
*	Arguments:		x0 as int16_t *c
*					x1 as const int16_t *a
*					x2 as const int16_t *b
*					x3 as const int16_t* zetas
*	Notes:			- q = 7681 and qinv = 57857 are stored in the vector v15
*					- 768 * 16bits for each A and B loaded as 6 vectors in 16 iterations.
*					  The result vector C is also stored as 4 vectors in each iteration.
*					- basemul macro is called twice in each iteration.
**************************************************/
.global NTTRU_AARCH64_basemul_arm
NTTRU_AARCH64_basemul_arm:
    mov		w4, 7681
  	mov		v15.h[0], w4		// v15.s[0] = q = 7681
  	mov		w4, 57857
    mov		v15.h[1], w4 		// v15.s[1] = qinv = 57857     q^(-1) mod 2^16
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
	basemul4
    ret
