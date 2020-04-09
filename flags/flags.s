/*
Benchmark with: as -o udiv.o udiv.s && gcc -o udiv udiv.o && for ((i=0; i<5; i++)); do time ./udiv; done
*/
.global main

.data
fmtcmn:
        .asciz  "%x: cmn %x, %x\n"
fmtcmp:
        .asciz  "%x: cmp %x, %x\n"

.text
main:
mov x6, 0x0
1:
strb w6, [sp, -16]!
bfm x2, x6, #0, #4
bfi x2, x2, #4, #4
bfi x2, x2, #8, #8
bfi x2, x2, #16, #16
bfi x2, x2, #32, #32
bfm x3, x6, #4, #8
bfi x3, x3, #4, #4
bfi x3, x3, #8, #8
bfi x3, x3, #16, #16
bfi x3, x3, #32, #32


        cmp     x2, x3
        mrs     x1, NZCV
        lsr     x1, x1, #28
        ldr     x0,=fmtcmp
        bl      printf
ldrb w6, [sp]
bfm x2, x6, #0, #4
bfi x2, x2, #4, #4
bfi x2, x2, #8, #8
bfi x2, x2, #16, #16
bfi x2, x2, #32, #32
bfm x3, x6, #4, #8
bfi x3, x3, #4, #4
bfi x3, x3, #8, #8
bfi x3, x3, #16, #16
bfi x3, x3, #32, #32
        cmn     x2, x3
        mrs     x1, NZCV
        lsr     x1, x1, #28
        ldr     x0,=fmtcmn
        bl      printf
ldrb w6, [sp], #16

add x6, x6, 1
cmp x6, 0x100
b.ne 1b
        mov     x8, #93
        svc     0
