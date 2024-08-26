
/* CORE MACROS */

/*************************************************	
*	Macro Name:		mbarret
*	Description:	Vectorized Barrett Reduction
*	Arguments:		a as va.8h = [a0, a1, ..., a7], 
*								vq.8h = [q, -, v, ...]
*	Intermediate Values/Vectors:
*								v10 as vd
**************************************************/
.macro mbarret a
    sqdmulh 	v4.8h, v\a\().8h, v15.h[2]   	// v4 = (2 * a * const v)_HI
	sshr 		v4.8h, v4.8h, 12			    // t: v4 <- v4 >> 12 (right shift)
	mls		    v\a\().8h, v4.8h, v15.h[0]		// a <- a - q * t
.endm

.macro fqred a
    mov         v4.16b, v\a\().16b //a
	and         v\a\().16b, v\a\().16b, v3.16b //t
	sshr        v4.8h, v4.8h, 13    //right shift 13bit
	sub         v\a\().8h, v\a\().8h, v4.8h
	sshl        v4.8h, v4.8h, v5.8h     //left shift 9bit a<<9
	add         v\a\().8h, v\a\().8h, v4.8h
.endm

.macro fqcsubq a
    mov         v4.16b, v\a\().16b //a
	sshr        v\a\().8h, v\a\().8h, 15
	and         v\a\().16b, v\a\().16b, v2.16b
	add         v\a\().8h, v4.8h, v\a\().8h
	sub         v\a\().8h, v\a\().8h, v2.8h
	mov         v4.16b, v\a\().16b //a
	sshr        v\a\().8h, v\a\().8h, 15
	and         v\a\().16b, v\a\().16b, v2.16b
	add         v\a\().8h, v4.8h, v\a\().8h
.endm

.macro fqredcsubq a
    mov         v4.16b, v\a\().16b //a
	and         v\a\().16b, v\a\().16b, v3.16b //t
	sshr        v4.8h, v4.8h, 13    //right shift 13bit
	sub         v\a\().8h, v\a\().8h, v4.8h
	sshl        v4.8h, v4.8h, v5.8h     //left shift 9bit a<<9
	add         v\a\().8h, v\a\().8h, v4.8h
    mov         v4.16b, v\a\().16b //a
	sshr        v\a\().8h, v\a\().8h, 15
	and         v\a\().16b, v\a\().16b, v2.16b
	add         v\a\().8h, v4.8h, v\a\().8h
	sub         v\a\().8h, v\a\().8h, v2.8h
	mov         v4.16b, v\a\().16b //a
	sshr        v\a\().8h, v\a\().8h, 15
	and         v\a\().16b, v\a\().16b, v2.16b
	add         v\a\().8h, v4.8h, v\a\().8h
.endm


.macro fqmul c, a, b
    sqdmulh     v1.8h, v\a\().8h, v\b\().8h     // 2ab_H = (2 * a * b)_HI
	mul 		v2.8h, v\a\().8h, v\b\().8h     // ab_L = (a * b)_LO
	mul 		v2.8h, v2.8h, v15.h[1]      	// qiab_L = (QINV * ab_L)_LO
	sqdmulh     v2.8h, v2.8h, v15.h[0]  		// 2u = (2 * Q * qiab_L)_HI
	shsub 	    v\c\().8h, v1.8h, v2.8h     	// t = (2ab_H - 2u) / 2 = ab_H - u 
.endm


.macro fqinv a
	fqmul       4, \a, \a   // i=1 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=2 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=3 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=4 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=5 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=6 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=7 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=8 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4 //i=9
	fqmul       4, 4, 4   // i=10 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=11 a=a*a
	fqmul       \a, \a, 4 //t=t*a
	fqmul       4, 4, 4   // i=12 a=a*a
	fqmul       \a, \a, 4 //t=t*a
.endm

.macro addxor a, b, c, d, e, f, g, h, k
	add    V\a\().8H, V\a\().8H, V\b\().8H //4
	add    V\c\().8H, V\c\().8H, V\d\().8H
	add    V\e\().8H, V\e\().8H, V\f\().8H
	add    V\g\().8H, V\g\().8H, V\h\().8H
	add    V\a\().8H, V\a\().8H, V\c\().8H //8
	add    V\b\().8H, V\e\().8H, V\g\().8H
	add    V\k\().8H, V\a\().8H, V\b\().8H //16
.endm

/* REDUCTION GROUPINGS */

/*************************************************	
*	Macro Name:		mbarret16
*	Description:	Apply Barrett Reduction to 16 vectors
*	Arguments:		Vector numbers a0 ... a15 
*					(not vector 15 which is reserved for constants) 
**************************************************/
.macro mbarret16 a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
	// load constants for Barrett Reduction
	mov w4, 7681
	mov v15.h[0], w4		// v15.s[0] = q = 7681
	mov w4, 17474
	mov v15.h[2], w4 		// v15.s[2] = v = 17474 used in Barrets reduction
	// Barrett Reduction
	mbarret \a0
	mbarret \a1
	mbarret \a2
	mbarret \a3
	mbarret \a4
	mbarret \a5
	mbarret \a6
	mbarret \a7
	mbarret \a8
	mbarret \a9
	mbarret \a10
	mbarret \a11
	mbarret \a12
	mbarret \a13
	mbarret \a14
	mbarret \a15
.endm



/* Shuffle Ops */
// Old A0 = Ax0 Ax1, B0 = Bx0 Bx1
// New A0 = Ax0 Bx0, A1 = Ax1 Bx1
.macro shuffle4 A0, A1, A2, B0, B1, B2
    mov     v4.16b, v\A0\().16b //v4=v6
	trn1	v\A0\().2d, v\A0\().2d, v\B0\().2d //v6=v6低+v9低
	trn2	v\B0\().2d, v4.2d, v\B0\().2d //v9=v6高+v9高
	
	mov     v4.16b, v\A1\().16b //v4=v7
	trn1	v\A1\().2d, v\A1\().2d, v\B1\().2d //v7=v7低+v10低
	trn2	v\B1\().2d, v4.2d, v\B1\().2d //v10=v7高+v10高

	mov     v4.16b, v\A2\().16b //v4=v8
	trn1	v\A2\().2d, v\A2\().2d, v\B2\().2d //v8=v8低+v11低
	trn2	v\B2\().2d, v4.2d, v\B2\().2d //v11=v8高+v11高
.endm

// Old A0 = Ax0 Ax1 Ax2 Ax3, B0 = Bx0 Bx1 Bx2 Bx3
// New A0 = Ax0 Bx0 Ax2 Bx2, A1 = Ax1 Bx1 Ax3 Bx3
.macro shuffle2 A0, A1, A2, B0, B1, B2
    mov     v4.16b, v\A0\().16b //v4=v6
	trn1	v\A0\().4s, v\A0\().4s, v\B1\().4s //v6=v6低+v10低
	trn2	v\B1\().4s, v4.4s, v\B1\().4s //v10=v6高+v10高
	
	mov     v4.16b, v\A2\().16b //v4=v8
	trn1	v\A2\().4s, v\B0\().4s, v\A2\().4s //v8=v9低+v8低
	trn2	v\B0\().4s, v\B0\().4s, v4.4s //v9=v9高+v8高

	mov     v4.16b, v\A1\().16b //v4=v7
	trn1	v\A1\().4s, v\A1\().4s, v\B2\().4s //v7=v7低+v11低
	trn2	v\B2\().4s, v4.4s, v\B2\().4s //v11=v7高+v11高
.endm


// Old A0 = Ax0 Ax1 Ax2 Ax3 Ax4 Ax5 Ax6 Ax7, B0 = Bx0 Bx1 Bx2 Bx3 Bx4 Bx5 Bx6 Bx7
// New A0 = Ax0 Bx0 Ax2 Bx2 Ax4 Bx4 Ax6 Bx6, A1 = Ax1 Bx1 Ax3 Bx3 Ax5 Bx5 Ax7 Bx7
.macro shuffle1 A0, A1, A2, B0, B1, B2
    mov     v4.16b, v\A0\().16b //v4=v6
	trn1	v\A0\().8h, v\A0\().8h, v\B0\().8h //v6=v6低+v9低
	trn2	v\B0\().8h, v4.8h, v\B0\().8h //v9=v6高+v9高
	
	mov     v4.16b, v\A1\().16b //v4=v7
	trn1	v\A1\().8h, v\B1\().8h, v\A1\().8h //v7=v7低+v10低
	trn2	v\B1\().8h, v\B1\().8h, v4.8h //v10=v7高+v10高

	mov     v4.16b, v\A2\().16b //v4=v8
	trn1	v\A2\().8h, v\A2\().8h, v\B2\().8h //v8=v8低+v11低
	trn2	v\B2\().8h, v4.8h, v\B2\().8h //v11=v8高+v11高
.endm

.macro shuffle5 A0, A1, A2, B0, B1, B2
    mov     v4.16b, v\A1\().16b
	mov     v\A1\().16b, v\A2\().16b
	mov     v\A2\().16b, v\B1\().16b
	mov     v\B1\().16b, v\B0\().16b
	mov     v\B0\().16b, v4.16b
.endm

.macro sswitch A0, A1
    mov     v4.16b, v\A1\().16b
	mov     v\A1\().16b, v\A0\().16b
	mov     v\A0\().16b, v4.16b
.endm



