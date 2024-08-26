/* ARMv8 implementation of NTT-functions */
/* Called in NTT.H */
/* New version (v2) */

// Requires fqmul, shuffle4, shuffle2
.include "macros.inc"

/*************************************************
*	Macro Name:		butterfly
*	Description:	ButterFly operation in NTT
*					i.e. (a, b) <- (a + b*z, a - b*z)
*	Arguments:		a as va.8h = [a0, a1, ..., a7],
*					b as vb.8h = [b0, b1, ..., b7],
*					zetas as vz.8h = [z0, z1, ..., z7]
*	Intermediate Values/Vectors:
*					v14 as vc
**************************************************/
.macro butterfly1 a, b, zetas  //Decomposition
	fqmul	14, \zetas, \b
	add     v\b\().8h, v\a\().8h, v\b\().8h
	sub	    v\b\().8h, v\b\().8h, v14.8h
	add  	v\a\().8h, v\a\().8h, v14.8h
.endm


.macro butterfly2 a, b, zetas  //7 radix-2
	fqmul	14, \zetas, \b
	sub	    v\b\().8h, v\a\().8h, v14.8h
	mbarret \b
	add	    v\a\().8h, v\a\().8h, v14.8h
    mbarret \a
.endm

.macro butterfly a, b, zetas  //7 radix-2 lazy reduction
	fqmul	14, \zetas, \b
	sub	    v\b\().8h, v\a\().8h, v14.8h
	add	    v\a\().8h, v\a\().8h, v14.8h
.endm

.macro level8
	ld1r	{v0.8h}, [x1], #2			// Zeta vector z1:...:z1
	// x0 at r0
	ld1   {v6.8h-v9.8h}, [x0], #64	    // after: x0 at r32
    ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	add	x0, x0, #576				// after: x0 at r384
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r416
    ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r448
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r480
	sub	x0, x0, #960				// after: x0 at r0
    
	butterfly1 6, 20, 0
    butterfly1 7, 21, 0
    butterfly1 8, 22, 0
    butterfly1 9, 23, 0
    butterfly1 10, 24, 0
    butterfly1 11, 25, 0
	butterfly1 12, 26, 0
	butterfly1 13, 27, 0
	butterfly1 16, 28, 0
	butterfly1 17, 29, 0
	butterfly1 18, 30, 0
	butterfly1 19, 31, 0 //0-384~95-479

    st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	add 	x0, x0, #576				// after: x0 at r384
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r416
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r448
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r480
	sub	x0, x0, #768				// after: x0 at r96
	// x0 at r96
	ld1   {v6.8h-v9.8h}, [x0], #64	    // after: x0 at r128
    ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r160
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r192
	add	x0, x0, #576				// after: x0 at r480
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r512
    ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r544
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r576
	sub	x0, x0, #960				// after: x0 at r96

	butterfly1 6, 20, 0
    butterfly1 7, 21, 0
    butterfly1 8, 22, 0
    butterfly1 9, 23, 0
    butterfly1 10, 24, 0
    butterfly1 11, 25, 0
	butterfly1 12, 26, 0
	butterfly1 13, 27, 0
	butterfly1 16, 28, 0
	butterfly1 17, 29, 0
	butterfly1 18, 30, 0
	butterfly1 19, 31, 0 //96-480~191-575

	st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r128
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r160
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r192
	add 	x0, x0, #576				// after: x0 at r480
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r512
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r544
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r576
	sub	x0, x0, #768				// after: x0 at r192
	// x0 at r192
	ld1   {v6.8h-v9.8h}, [x0], #64	    // after: x0 at r224
    ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r256
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r288
	add	x0, x0, #576				// after: x0 at r576
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r608
    ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r640
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r672
	sub	x0, x0, #960				// after: x0 at r192
    
	butterfly1 6, 20, 0
    butterfly1 7, 21, 0
    butterfly1 8, 22, 0
    butterfly1 9, 23, 0
    butterfly1 10, 24, 0
    butterfly1 11, 25, 0
	butterfly1 12, 26, 0
	butterfly1 13, 27, 0
	butterfly1 16, 28, 0
	butterfly1 17, 29, 0
	butterfly1 18, 30, 0
	butterfly1 19, 31, 0 //192-576~287-671

    st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r224
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r256
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r288
	add 	x0, x0, #576				// after: x0 at r576
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r608
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r640
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r672
	sub	x0, x0, #768				// after: x0 at r288
	// x0 at r288
	ld1   {v6.8h-v9.8h}, [x0], #64	    // after: x0 at r320
    ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r352
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r384
	add	x0, x0, #576				// after: x0 at r672
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r704
    ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r736
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r768
	sub	x0, x0, #960				// after: x0 at r288
    
	butterfly1 6, 20, 0
    butterfly1 7, 21, 0
    butterfly1 8, 22, 0
    butterfly1 9, 23, 0
    butterfly1 10, 24, 0
    butterfly1 11, 25, 0
	butterfly1 12, 26, 0
	butterfly1 13, 27, 0
	butterfly1 16, 28, 0
	butterfly1 17, 29, 0
	butterfly1 18, 30, 0
	butterfly1 19, 31, 0 //288-383~672-767

    st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r320
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r352
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r384
	add 	x0, x0, #576				// after: x0 at r672
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r704
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r736
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r768
	sub	x0, x0, #1536				// after: x0 at r0
.endm

.macro level7

	ld1r	{v0.8h}, [x1], #2			// Zeta vector z2:...:z2 

	/* Load the half's half */
	ld1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	add	x0, x0, #192				// after: x0 at r192
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r224
	ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r256
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r288
	sub	x0, x0, #576				// after: x0 at r0
	/* Level 7 */
	butterfly 6, 20, 0
    butterfly 7, 21, 0
    butterfly 8, 22, 0
    butterfly 9, 23, 0
    butterfly 10, 24, 0
    butterfly 11, 25, 0
	butterfly 12, 26, 0
	butterfly 13, 27, 0
	butterfly 16, 28, 0
	butterfly 17, 29, 0
	butterfly 18, 30, 0
	butterfly 19, 31, 0 // 0-192~95-287   96-288~191-383

    st1   {v6.8h-v9.8h}, [x0], #64	    // after: x0 at r32
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	add 	x0, x0, #192				// after: x0 at r192
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r224
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r256
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r288
.endm


.macro levels6to1
	/* Load the half's half */
	ld1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192
	sub	x0, x0, #384				// after: x0 at r0

	/* Level 6 */
	ld1r	{v0.8h}, [x1], #2	// Zeta vectors [z4]

	butterfly2 6, 20, 0 
    butterfly2 7, 21, 0
    butterfly2 8, 22, 0
    butterfly2 9, 23, 0
    butterfly2 10, 24, 0
    butterfly2 11, 25, 0  
	butterfly2 12, 26, 0
	butterfly2 13, 27, 0
	butterfly2 16, 28, 0
	butterfly2 17, 29, 0
	butterfly2 18, 30, 0
	butterfly2 19, 31, 0 // 0-96~95-191

	/* Level 5 */
	ld1r	{v0.8h}, [x1], #2	// Zeta vectors [z8]
	
	butterfly 6, 12, 0 
	butterfly 7, 13, 0
	butterfly 8, 16, 0
	butterfly 9, 17, 0
	butterfly 10, 18, 0
	butterfly 11, 19, 0  //0-48~47-95
        
	ld1r	{v0.8h}, [x1], #2	// Zeta vectors [z9]
	butterfly 20, 26, 0
	butterfly 21, 27, 0
	butterfly 22, 28, 0
	butterfly 23, 29, 0
	butterfly 24, 30, 0
	butterfly 25, 31, 0 // 96-144~143-191
	
	/* Level 4 */
	ld1r	{v0.8h}, [x1], #2			// Zeta vectors [z16]
	butterfly 6, 9, 0 
	butterfly 7, 10, 0
	butterfly 8, 11, 0 //0-24~23-47

    ld1r	{v0.8h}, [x1], #2			// Zeta vectors [z17]
	butterfly 12, 17, 0
	butterfly 13, 18, 0
	butterfly 16, 19, 0  //48-72~71-95

    ld1r	{v0.8h}, [x1], #2			// Zeta vectors [z18]
	butterfly 20, 23, 0
	butterfly 21, 24, 0
	butterfly 22, 25, 0 //96-120~119-143

    ld1r	{v0.8h}, [x1], #2			// Zeta vectors [z19]
	butterfly 26, 29, 0
	butterfly 27, 30, 0
	butterfly 28, 31, 0 // 144-168~167-191

	/* Level 3 */
	shuffle4 6, 7, 8 ,9, 10, 11
	shuffle4 12, 13, 16, 17, 18, 19
	shuffle4 20, 21, 22, 23, 24, 25
	shuffle4 26, 27, 28, 29, 30, 31
	
	ld1	{v0.8h}, [x1], #16	
	butterfly2 6, 10, 0
	butterfly2 9, 8, 0
	butterfly2 7, 11, 0 //v0:z32	z32 z32	z32	z33	z33	z33	z33
    
	ld1	{v0.8h}, [x1], #16	
	butterfly2 12, 18, 0
	butterfly2 17, 16, 0
	butterfly2 13, 19, 0 //v1:z34 z34 z34 z34 z35 z35 z35 z35
    
	ld1	{v0.8h}, [x1], #16
	butterfly2 20, 24, 0
	butterfly2 23, 22, 0
	butterfly2 21, 25, 0 //v2:z36 z36 z36 z36 z37 z37 z37 z37
    
	ld1	{v0.8h}, [x1], #16
	butterfly2 26, 30, 0
	butterfly2 29, 28, 0
	butterfly2 27, 31, 0 //v3:z38 z38 z38 z38 z39 z39 z39 z39
	
	/* Level 2 */
	shuffle2 6, 7, 8 ,9, 10, 11
	shuffle2 12, 13, 16, 17, 18, 19
	shuffle2 20, 21, 22, 23, 24, 25
	shuffle2 26, 27, 28, 29, 30, 31
	
	ld1	{v0.8h}, [x1], #16	
	butterfly 6, 9, 0
	butterfly 10, 7, 0
	butterfly 8, 11, 0 //v0:z64 z64	z65	z65	z66	z66	z67	z67
    
	ld1	{v0.8h}, [x1], #16
	butterfly 12, 17, 0
	butterfly 18, 13, 0
	butterfly 16, 19, 0 //v1:z68 z68 z69 z69 z70 z70 z71 z71
    
	ld1	{v0.8h}, [x1], #16
	butterfly 20, 23, 0
	butterfly 24, 21, 0
	butterfly 22, 25, 0 //v2:z72 z72 z73 z73 z74 z74 z75 z75
    
	ld1	{v0.8h}, [x1], #16
	butterfly 26, 29, 0
	butterfly 30, 27, 0
	butterfly 28, 31, 0 //v3:z76 z76 z77 z77 z78 z78 z79 z79

	/* Level 1 */
	shuffle1 6, 7, 8 ,9, 10, 11
	shuffle1 12, 13, 16, 17, 18, 19
	shuffle1 20, 21, 22, 23, 24, 25
	shuffle1 26, 27, 28, 29, 30, 31
    
	ld1	{v0.8h}, [x1], #16	
	butterfly 6, 10, 0
	butterfly 9, 8, 0
	butterfly 7, 11, 0 //v0:z128 z129 z130 z131 z132 z133 z134 z135
    
	ld1	{v0.8h}, [x1], #16
	butterfly 12, 18, 0
	butterfly 17, 16, 0 
	butterfly 13, 19, 0 //v1:z136 z137 z138 z139 z140 z141 z142 z143
    
	ld1	{v0.8h}, [x1], #16
	butterfly 20, 24, 0
	butterfly 23, 22, 0
	butterfly 21, 25, 0 //v2:z144 z145 z146 z147 z148 z149 z150 z151
    
	ld1	{v0.8h}, [x1], #16
	butterfly 26, 30, 0
	butterfly 29, 28, 0
	butterfly 27, 31, 0 //v3:z152 z153 z154 z155 z156 z157 z158 z159

	/*shuffle1 6, 10, 8 ,9, 7, 11
	shuffle1 12, 18, 16, 17, 13, 19
	shuffle1 20, 24, 22, 23, 21, 25
	shuffle1 26, 30, 28, 29, 27, 31
	
	shuffle2 6, 7, 9 ,8, 10, 11
	shuffle2 12, 13, 17, 16, 18, 19
	shuffle2 20, 21, 23, 22, 24, 25
	shuffle2 26, 27, 29, 28, 30, 31

	shuffle4 6, 7, 8 ,9, 10, 11
	shuffle4 12, 13, 16, 17, 18, 19
	shuffle4 20, 21, 22, 23, 24, 25
	shuffle4 26, 27, 28, 29, 30, 31*/
	
	st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
    st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192
.endm


.global ntt_arm
ntt_arm:
	// pre-operations
	mov		w4, 7681
  	mov		v15.h[0], w4		// v15.s[0] = q = 7681
  	mov		w4, 57857
    mov		v15.h[1], w4 		// v15.s[1] = qinv = 57857     q^(-1) mod 2^16
    level8
	level7
	sub		x0, x0, #384				// after: x0 at r96
	level7
	level7
	sub		x0, x0, #384				// after: x0 at r480
	level7
	sub		x0, x0, #1536				// after: x0 at r0
	levels6to1
	levels6to1
	levels6to1
	levels6to1
	ret