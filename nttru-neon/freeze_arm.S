/* ARMv8 implementation of Reductions */
/* Called in REDUCE.H */ 

// Include macros fqcsubq
.include "macros.inc"

.macro polyfreeze
    ld1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	ld1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	ld1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	ld1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	ld1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
	ld1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192
    fqcsubq 6
    fqcsubq 7
    fqcsubq 8
    fqcsubq 9
    fqcsubq 10
    fqcsubq 11
    fqcsubq 12
    fqcsubq 13
    fqcsubq 16
    fqcsubq 17
    fqcsubq 18
    fqcsubq 19
    fqcsubq 20
    fqcsubq 21
    fqcsubq 22
    fqcsubq 23
    fqcsubq 24
    fqcsubq 25
    fqcsubq 26
    fqcsubq 27
    fqcsubq 28
    fqcsubq 29
    fqcsubq 30
    fqcsubq 31
    sub x0, x0, #384 //r0
    st1   {v6.8h-v9.8h}, [x0], #64	// after: x0 at r32
	st1   {v10.8h-v13.8h}, [x0], #64	// after: x0 at r64
	st1   {v16.8h-v19.8h}, [x0], #64	// after: x0 at r96
	st1   {v20.8h-v23.8h}, [x0], #64	// after: x0 at r128
	st1   {v24.8h-v27.8h}, [x0], #64	// after: x0 at r160
	st1   {v28.8h-v31.8h}, [x0], #64	// after: x0 at r192

.endm

.global freeze_arm
freeze_arm:
    ld1r  {v2.8h}, [x1]
    polyfreeze
    polyfreeze
    polyfreeze
    polyfreeze
	ret