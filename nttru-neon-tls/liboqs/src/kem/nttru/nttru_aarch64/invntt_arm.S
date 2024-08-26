/* ARMv8 implementation of NTT-functions */
/* Called in NTT.H */
/* New version (v2) */

// Requires fqmul, shuffle4, shuffle2
.include "macros.inc"

/*************************************************
*	Macro Name:		butterfly
*	Description:	ButterFly operation in INTT
*	Arguments:		a as va.8h = [a0, a1, ..., a7],
*					b as vb.8h = [b0, b1, ..., b7],
*					zetas as vz.8h = [z0, z1, ..., z7]
*	Intermediate Values/Vectors: v14
**************************************************/
.macro butterfly2 a, b, zetas //7 radix-2
	mov		v14.16b, v\a\().16b					// t <- va
	add		v\a\().8h, v14.8h, v\b\().8h		// va = vb + t
	// va = BarretRed(va)
	mbarret   \a
	sub		v\b\().8h, v14.8h, v\b\().8h 		// vb = t - vb
	fqmul 	\b, \zetas, \b						// vb = vb * zetas
.endm


.macro butterfly a, b, zetas //7 radix-2 lazy reduction
	mov		v14.16b, v\a\().16b					// t <- va
	add		v\a\().8h, v14.8h, v\b\().8h		// va = vb + t
	sub		v\b\().8h, v14.8h, v\b\().8h 		// vb = t - vb
	fqmul 	\b, \zetas, \b						// vb = vb * zetas
.endm

.macro butterfly1 a, b, zetas  // Combination
    sub     v14.8h, v\a\().8h, v\b\().8h        //t = va - vb
	fqmul	14, \zetas, 14                      //t = zetas*t
	add     v\a\().8h, v\a\().8h, v\b\().8h     //va= va + vb
	sub	    v\a\().8h, v\a\().8h, v14.8h        //va= va - t
	fqmul   \a, 3, \a    //va = (1U<<24)%Q * va
	fqmul   \b, 5, 14    //vb = (1U<<25)%Q * t
.endm

.macro levels1to6
	/* Load the half's half */
	ld1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192
	sub	x0, x0, #384				// after: x0 at r0

	
	
	/* Level 1 */
	ld1	{v0.8h}, [x1], #16	//z_inv 0 1 2 3 4 5 6 7
	butterfly 6, 10, 0
	butterfly 9, 8, 0
	butterfly 7, 11, 0  
    
	ld1	{v0.8h}, [x1], #16  //z_inv 8 9 10 11 12 13 14 15
	butterfly 12, 18, 0
	butterfly 17, 16, 0
	butterfly 13, 19, 0
    
	ld1	{v0.8h}, [x1], #16  //z_inv 16 17 18 19 20 21 22 23
	butterfly 20, 24, 0
	ButterFly 23, 22, 0
	butterfly 21, 25, 0 
    
	ld1	{v0.8h}, [x1], #16  //z_inv 24 25 26 27 28 29 30 31
	butterfly 26, 30, 0
	butterfly 29, 28, 0
	butterfly 27, 31, 0

	/* level 2 */
	shuffle1 6, 10, 8 ,9, 7, 11
	shuffle1 12, 18, 16, 17, 13, 19
	shuffle1 20, 24, 22, 23, 21, 25
	shuffle1 26, 30, 28, 29, 27, 31

	ld1	{v0.8h}, [x1], #16	//z_inv 128 128 129 129 130 130 131 131
	butterfly2 6, 9, 0
	butterfly2 10, 7, 0
	butterfly 8, 11, 0
    
	ld1	{v0.8h}, [x1], #16  //z_inv 132 132 133 133 134 134 135 135
	butterfly2 12, 17, 0
	butterfly2 18, 13, 0
	butterfly 16, 19, 0
    
	ld1	{v0.8h}, [x1], #16  //z_inv 136 136 137 137 138 138 139 139
	butterfly2 20, 23, 0
	butterfly2 24, 21, 0
	butterfly 22, 25, 0
    
	ld1	{v0.8h}, [x1], #16  //z_inv 140 140 141 141 142 142 143 143
	butterfly2 26, 29, 0
	butterfly2 30, 27, 0
	butterfly 28, 31, 0

	/* level 3 */
	shuffle2 6, 7, 9 ,8, 10, 11
	shuffle2 12, 13, 17, 16, 18, 19
	shuffle2 20, 21, 23, 22, 24, 25
	shuffle2 26, 27, 29, 28, 30, 31

	ld1	{v0.8h}, [x1], #16	//z_inv 192 192 192 192 193 193 193 193
	butterfly 6, 10, 0
	butterfly2 9, 8, 0
	butterfly 7, 11, 0 
    
	ld1	{v0.8h}, [x1], #16  //z_inv 194 194 194 194 195 195 195 195
	butterfly 12, 18, 0
	butterfly2 17, 16, 0
	butterfly 13, 19, 0
    
	ld1	{v0.8h}, [x1], #16  //z_inv 196 196 196 196 197 197 197 197
	butterfly 20, 24, 0
	butterfly2 23, 22, 0
	butterfly 21, 25, 0 
    
	ld1	{v0.8h}, [x1], #16  //z_inv 198 198 198 198 199 199 199 199
	butterfly 26, 30, 0
	butterfly2 29, 28, 0
	butterfly 27, 31, 0

	/* level 4 */
	shuffle4 6, 7, 8 ,9, 10, 11
	shuffle4 12, 13, 16, 17, 18, 19
	shuffle4 20, 21, 22, 23, 24, 25
	shuffle4 26, 27, 28, 29, 30, 31

	ld1r	{v0.8h}, [x1], #2			// Zeta_inv vectors [z224]
	butterfly2 6, 9, 0 
	butterfly2 7, 10, 0
	butterfly 8, 11, 0                 //0-24~23-47

    ld1r	{v0.8h}, [x1], #2			// Zeta_inv vectors [z225]
	butterfly2 12, 17, 0
	butterfly2 13, 18, 0
	butterfly 16, 19, 0                 //48-72~71-95

    ld1r	{v0.8h}, [x1], #2			// Zeta_inv vectors [z226]
	butterfly2 20, 23, 0
	butterfly2 21, 24, 0
	butterfly 22, 25, 0                //96-120~119-143

    ld1r	{v0.8h}, [x1], #2			// Zeta vectors [z227]
	butterfly2 26, 29, 0
	butterfly2 27, 30, 0
	butterfly 28, 31, 0                // 144-168~167-191
	
	/* Level 5 */
	ld1r	{v0.8h}, [x1], #2	// Zeta_inv vectors [z240]

	butterfly 6, 12, 0 
	butterfly 7, 13, 0
	butterfly2 8, 16, 0
	butterfly 9, 17, 0
	butterfly 10, 18, 0
	butterfly 11, 19, 0  //0-48~47-95
        
	ld1r	{v0.8h}, [x1], #2	// Zeta_inv vectors [z241]
	butterfly 20, 26, 0
	butterfly 21, 27, 0
	butterfly2 22, 28, 0
	butterfly 23, 29, 0
	butterfly 24, 30, 0
	butterfly 25, 31, 0 // 96-144~143-191

	/* Level 6 */
	ld1r	{v0.8h}, [x1], #2	// Zeta vectors [z248]

	butterfly2 6, 20, 0 
    butterfly2 7, 21, 0
    butterfly 8, 22, 0
    butterfly 9, 23, 0
    butterfly 10, 24, 0
    butterfly 11, 25, 0  
	butterfly 12, 26, 0
	butterfly 13, 27, 0
	butterfly 16, 28, 0
	butterfly 17, 29, 0
	butterfly 18, 30, 0
	butterfly 19, 31, 0 // 0-96~95-191

    st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
    st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
    st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192
.endm

.macro level7

	ld1r	{v0.8h}, [x1], #2			// Zeta vector [z252]

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
	butterfly2 6, 20, 0
    butterfly2 7, 21, 0
    butterfly2 8, 22, 0
    butterfly2 9, 23, 0
    butterfly2 10, 24, 0
    butterfly2 11, 25, 0
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

.macro level8
	ld1r	{v0.8h}, [x1], #2			// Zeta_inv vector z[254]
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
	//sub	x0, x0, #1536				// after: x0 at r0
.endm



.global NTTRU_AARCH64_invntt_arm
NTTRU_AARCH64_invntt_arm:
	// pre-operations
	mov		w4, 7681
  	mov		v15.h[0], w4		// v15.s[0] = q = 7681
  	mov		w4, 57857
    mov		v15.h[1], w4 		// v15.s[1] = qinv = 57857     q^(-1) mod 2^16
	mov     w4, 17474
	mov     v15.h[2], w4 		// v15.s[2] = v = 17474 used in Barrets reduction
    levels1to6
	levels1to6
	levels1to6
	levels1to6
    sub     x0, x0, #1536               //after: x0 at r0
	level7
	sub		x0, x0, #384				// after: x0 at r96
	level7
	level7
	sub		x0, x0, #384				// after: x0 at r480
	level7
	sub		x0, x0, #1536				// after: x0 at r0
	ld1r {v3.8h}, [x2], #2
	ld1r {v5.8h}, [x2], #2
    level8
	ret