/*
Benchmark with: as -o umulh+lsr.o umulh+lsr.s && gcc -o umulh+lsr umulh+lsr.o && for ((i=0; i<5; i++)); do time ./umulh+lsr; done
*/
.global main

.data
fmt:
        .asciz  "%d / %d = %d\n"

.text
main:
        mov     x1, #0xec73
        movk    x1, #0x0018, lsl #16
        mov     x2, #216
        mov     x11, #0x10000000
1:
        mov     x4, #0x425f
        movk    x4, #0x97b, lsl #16
        movk    x4, #0x25ed, lsl #32
        movk    x4, #0x97b4, lsl #48
        umulh   x3, x4, x1
        lsr     x3, x3, #7
        lsr     x5, x3, 10      // will always be 0
        add     x1, x1, x5
        subs    x11, x11, #1
        b.ne    1b
        ldr     x0,=fmt
        bl      printf
        mov     x8, #93
        svc     0
