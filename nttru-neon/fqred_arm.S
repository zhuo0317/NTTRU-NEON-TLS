/* ARMv8 implementation of Reductions */
/* Called in REDUCE.H */ 

// Include macros mbarret16
.include "macros.inc"

.macro polyfqred
    ld1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192
    fqred 6
    fqred 7
    fqred 8
    fqred 9
    fqred 10
    fqred 11
    fqred 12
    fqred 13
    fqred 16
    fqred 17
    fqred 18
    fqred 19
    fqred 20
    fqred 21
    fqred 22
    fqred 23
    fqred 24
    fqred 25
    fqred 26
    fqred 27
    fqred 28
    fqred 29
    fqred 30
    fqred 31
    sub x0, x0, #384 //r0
    st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192

.endm

.global poly_fqred_arm
poly_fqred_arm:
    ld1r {v3.8h}, [x1], #2
	ld1r {v5.8h}, [x1], #2
    polyfqred
    polyfqred
    polyfqred
    polyfqred
	ret