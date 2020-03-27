00000000000bdf20 <github.com/petemoore/homescreen/screendump/lib.Render>:
   bdf20:    f9400b81     ldr    x1, [x28, #16]                  // x1 = stack end
   bdf24:    910003e2     mov    x2, sp                          // x2 = stack pointer
   bdf28:    eb01005f     cmp    x2, x1                          // see if stack needs growing
   bdf2c:    54001349     b.ls    6f                             // if no stack, go grab some more
   bdf30:    f8190ffe     str    x30, [sp, #-112]!               // store x30 on stack
   bdf34:    f81f83fd     stur    x29, [sp, #-8]                 // store x29 on stack
   bdf38:    d10023fd     sub    x29, sp, #0x8                   // update frame pointer
   bdf3c:    d2800000     mov    x0, #0x0                        // x0 = 0 (loop counter i)
   bdf40:    1400005c     b    3f                                // jump forward to 3:
1:
   bdf44:    f9002fe7     str    x7, [sp, #88]                   // store a on stack
   bdf48:    b2400be1     orr    x1, xzr, #0x7                   // x1 = 7
   bdf4c:    cb070022     sub    x2, x1, x7                      // x2 = (7-a)
   bdf50:    9ac22523     lsr    x3, x9, x2                      // x3 = p >> (7-a)
   bdf54:    f101005f     cmp    x2, #0x40                       // compare (7-a) to 64
   bdf58:    9a9f3062     csel    x2, x3, xzr, cc                // x2 = p >> (7-a) if (7-a) < 64 else 0
   bdf5c:    92400042     and    x2, x2, #0x1                    // p >> (7-a) & 0x01 = c
   bdf60:    8b020442     add    x2, x2, x2, lsl #1              // x2 = 3 if c == 1 else 0 = c*3
   bdf64:    b27e03e3     orr    x3, xzr, #0x4                   // x3 = 4
   bdf68:    cb020065     sub    x5, x3, x2                      // x5 = 4-c*3
   bdf6c:    d3401ca5     ubfx    x5, x5, #0, #8                 // x5 = lower 8 bits of 4-c*3=4-c*3
   bdf70:    aa0403e6     mov    x6, x4                          // x6 = x4 = attr
   bdf74:    9ac524c8     lsr    x8, x6, x5                      // x8 = attr >> (4-c*3)
   bdf78:    f10100bf     cmp    x5, #0x40                       // compare 4-c*3 with 64
   bdf7c:    9a9f3105     csel    x5, x8, xzr, cc                // x5 = attr >> (4-c*3) if (4-c*3) < 64 else 0
   bdf80:    d3461c88     ubfx    x8, x4, #6, #2                 // x8 = bits 6-7 of attr
   bdf84:    92400108     and    x8, x8, #0x1                    // x8 = bit 7 of attr = ((attr>>6)&0x01)
   bdf88:    d2800669     mov    x9, #0x33                       // x9 = 0x33
   bdf8c:    1b087d28     mul    w8, w9, w8                      // w8 = 0x33 * ((attr>>6)&0x01)
   bdf90:    d100d108     sub    x8, x8, #0x34                   // x8 = 0x33*((attr>>6)&0x01)-52 = l in bits 0-7
   bdf94:    924000a5     and    x5, x5, #0x1                    // x5 = (attr>>(4-c*3))&0x01
   bdf98:    1b087ca5     mul    w5, w5, w8                      // w5 = (attr>>(4-c*3))&0x01 * (0x33*((attr>>6)&0x01)-52) = RED
   bdf9c:    390103e5     strb    w5, [sp, #64]                  // store RED on stack
   bdfa0:    d28000a5     mov    x5, #0x5                        // x5 = 5
   bdfa4:    cb0200aa     sub    x10, x5, x2                     // x10 = 5-c*3
   bdfa8:    d3401d4a     ubfx    x10, x10, #0, #8               // x10 = lowest 8 bits of (5-c*3) = 5-c*3
   bdfac:    9aca24cb     lsr    x11, x6, x10                    // x11 = attr >> (5-c*3)
   bdfb0:    f101015f     cmp    x10, #0x40                      // compare (5-c*3) to 64
   bdfb4:    9a9f316a     csel    x10, x11, xzr, cc              // x10 = attr>>(5-c*3) if (5-c*3)<64 else 0
   bdfb8:    9240014a     and    x10, x10, #0x1                  // x10 = (attr>>(5-c*3))&0x01
   bdfbc:    1b087d4a     mul    w10, w10, w8                    // w10 = ((attr>>(5-c*3))&0x01)*(0x33*((attr>>6)&0x01)-52) = GREEN
   bdfc0:    390107ea     strb    w10, [sp, #65]                 // store GREEN on stack
   bdfc4:    b24007ea     orr    x10, xzr, #0x3                  // x10 = 3
   bdfc8:    cb020142     sub    x2, x10, x2                     // x2 = 3-c*3
   bdfcc:    d3401c42     ubfx    x2, x2, #0, #8                 // x2 = lower 8 bits of 3-c*3=3-c*3
   bdfd0:    9ac224c6     lsr    x6, x6, x2                      // x6 = attr >> (3-c*3)
   bdfd4:    f101005f     cmp    x2, #0x40                       // compare (3-c*3) to 64
   bdfd8:    9a9f30c2     csel    x2, x6, xzr, cc                // x2 = attr >> (3-c*3) if (3-c*3)<64 else 0
   bdfdc:    92400042     and    x2, x2, #0x1                    // x2 = (attr>>(3-c*3))&0x01
   bdfe0:    1b087c42     mul    w2, w2, w8                      // w2 = ((attr>>(3-c*3))&0x01)*(0x33*((attr>>6)&0x01)-52) = BLUE
   bdfe4:    39010be2     strb    w2, [sp, #66]                  // store BLUE on stack
   bdfe8:    92800002     mov    x2, #0xffffffffffffffff         // x2 = -1
   bdfec:    39010fe2     strb    w2, [sp, #67]                  // store -1 on stack
   bdff0:    f00002e6     adrp    x6, 11c000 <runtime.munmap.stkobj>
   bdff4:    912100c6     add    x6, x6, #0x840                  // x6 = 0x11c840
   bdff8:    f90007e6     str    x6, [sp, #8]                    // store 0x11c840 on stack
   bdffc:    910103e8     add    x8, sp, #0x40                   // x8 = sp + 40
   be000:    f9000be8     str    x8, [sp, #16]                   // store (sp+40) on stack
   be004:    97fd6a03     bl    18810 <runtime.convT2Inoptr>     // call runtime.convT2Inoptr
   be008:    f9400fe0     ldr    x0, [sp, #24]                   // x0 = from stack (sp + 24)
   be00c:    f94013e1     ldr    x1, [sp, #32]                   // x1 = from stack (sp + 32)
   be010:    9140c3fb     add    x27, sp, #0x30, lsl #12         // x27 = sp + 0x030000
   be014:    f961e762     ldr    x2, [x27, #17352]               // x2 = [sp + 0x000343C8]
   be018:    f90007e2     str    x2, [sp, #8]                    // store it back on stack [sp +8]
   be01c:    f9402be3     ldr    x3, [sp, #80]                   // x3 = i
   be020:    d2801b04     mov    x4, #0xd8                       // x4 = 0xd8
   be024:    f94033e5     ldr    x5, [sp, #96]                   // x5 = int(i/216)
   be028:    9b048ca6     msub    x6, x5, x4, x3                 // x6 = i - int(i/216) * 216 = i%216
   be02c:    f9402fe7     ldr    x7, [sp, #88]                   // x7 = a
   be030:    8b060ce6     add    x6, x7, x6, lsl #3              // x6 = a + (i%216)*8
   be034:    910180c6     add    x6, x6, #0x60                   // x6 = 96 + a + (i%216)*8 = x
   be038:    f9000be6     str    x6, [sp, #16]                   // store x on stack
   be03c:    f94027e6     ldr    x6, [sp, #72]                   // x6 = y
   be040:    f9000fe6     str    x6, [sp, #24]                   // store x6 on stack
   be044:    f90013e0     str    x0, [sp, #32]                   // store x0 on stack (img/q ?)
   be048:    f90017e1     str    x1, [sp, #40]                   // store x1 on stack (img/q ?)
   be04c:    97ff9a7d     bl    a4a40 <image.(*NRGBA).Set>       // call image.(*NRGBA).Set
   be050:    f9402fe0     ldr    x0, [sp, #88]                   // x0 = a ?
   be054:    91000407     add    x7, x0, #0x1                    // x7 = a + 1
   be058:    f9402be0     ldr    x0, [sp, #80]                   // x0 = i
   be05c:    d2884be1     mov    x1, #0x425f
   be060:    f2a12f61     movk    x1, #0x97b, lsl #16
   be064:    f2c4bda1     movk    x1, #0x25ed, lsl #32
   be068:    f2f2f681     movk    x1, #0x97b4, lsl #48           // x1 = 0x97b425ed097b425f
   be06c:    f94033e2     ldr    x2, [sp, #96]                   // x2 = int(i/216)
   be070:    d29999a3     mov    x3, #0xcccd
   be074:    f2b99983     movk    x3, #0xcccc, lsl #16
   be078:    f2d99983     movk    x3, #0xcccc, lsl #32
   be07c:    f2f99983     movk    x3, #0xcccc, lsl #48           // x3 = 0xcccccccccccccccd
   be080:    3940e3e4     ldrb    w4, [sp, #56]                  // w4 = attribute byte
   be084:    d293aca5     mov    x5, #0x9d65
   be088:    f2a1e565     movk    x5, #0xf2b, lsl #16
   be08c:    f2dac905     movk    x5, #0xd648, lsl #32
   be090:    f2fe5725     movk    x5, #0xf2b9, lsl #48           // x5 = 0xf2b9d6480f2b9d65
   be094:    f94027e6     ldr    x6, [sp, #72]                   // x6 = y
   be098:    9101e3e8     add    x8, sp, #0x78                   // x8 = sp+0x78
   be09c:    3940c3e9     ldrb    w9, [sp, #48]                  // w9 = p
   be0a0:    d2800d8c     mov    x12, #0x6c                      // x12 = 108
2:
   be0a4:    f10020ff     cmp    x7, #0x8                        // a < 8 ?
   be0a8:    54fff4e3     b.cc    1b                             // if so jump back to 1:
   be0ac:    91000400     add    x0, x0, #0x1                    // i += 1
3:
   be0b0:    d285401b     mov    x27, #0x2a00                    // #10752
   be0b4:    f2a0007b     movk    x27, #0x3, lsl #16             // x27 = 0x32a00 = 207360
   be0b8:    eb1b001f     cmp    x0, x27                         // Has i loop completed?
   be0bc:    54000622     b.cs    4f                             // If so, jump forward to 4:
   be0c0:    d2884be1     mov    x1, #0x425f
   be0c4:    f2a12f61     movk    x1, #0x97b, lsl #16
   be0c8:    f2c4bda1     movk    x1, #0x25ed, lsl #32
   be0cc:    f2f2f681     movk    x1, #0x97b4, lsl #48           // x1 = 0x97b425ed097b425f = 10931403895531586143
   be0d0:    9bc07c22     umulh    x2, x1, x0                    // x2 = (10931403895531586143 * i) / 18446744073709551616 = int(i*16/27)
   be0d4:    d347fc42     lsr    x2, x2, #7                      // x2 = int(i/216)
   be0d8:    d29999a3     mov    x3, #0xcccd
   be0dc:    f2b99983     movk    x3, #0xcccc, lsl #16
   be0e0:    f2d99983     movk    x3, #0xcccc, lsl #32
   be0e4:    f2f99983     movk    x3, #0xcccc, lsl #48           // x3 = 0xcccccccccccccccd = 14757395258967641293
   be0e8:    9bc27c64     umulh    x4, x3, x2                    // x4 = 14757395258967641293 * int(i/216) / 2^64 = (4/5) * int(i/216)
   be0ec:    d344fc84     lsr    x4, x4, #4                      // x4 = int(int(i/216)/20)
   be0f0:    8b040884     add    x4, x4, x4, lsl #2              // x4 = 5 * int(int(i/216)/20)
   be0f4:    cb040844     sub    x4, x2, x4, lsl #2              // x4 = int(i/216) - 20 * int(int(i/216)/20) = (i/216)%20
   be0f8:    d293aca5     mov    x5, #0x9d65
   be0fc:    f2a1e565     movk    x5, #0xf2b, lsl #16
   be100:    f2dac905     movk    x5, #0xd648, lsl #32
   be104:    f2fe5725     movk    x5, #0xf2b9, lsl #48           // x5 = 0xf2b9d6480f2b9d65 = 17490246232850537829
   be108:    9bc07ca6     umulh    x6, x5, x0                    // x6 = 17490246232850537829 * i / 2^64 = int(i*128/135)
   be10c:    d34c3cc7     ubfx    x7, x6, #12, #4                // x7 = bits 12-15 of int(i*128/135) = (i/(216*20)) % 16
   be110:    8b0410e7     add    x7, x7, x4, lsl #4              // x7 = (i/(216*20))%16 + 16*((i/216)%20)
   be114:    d350fcc6     lsr    x6, x6, #16                     // x6 = int(i/(216*20*16))
   be118:    8b0608c6     add    x6, x6, x6, lsl #2              // x6 = 5*int(i/(216*20*16))
   be11c:    8b0618e7     add    x7, x7, x6, lsl #6              // x7 = (i/(216*20))%16 + 16*((i/216)%20) + 320*int(i/216*20*16)
   be120:    9101e3e8     add    x8, sp, #0x78                   // x8 = sp + 15 double words
   be124:    38606909     ldrb    w9, [x8, x0]                   // w9 = byte at [sp + 0x78 + i] : p ?
   be128:    d341fc0a     lsr    x10, x0, #1                     // x10 = int(i/2)
   be12c:    9bca7c2b     umulh    x11, x1, x10                  // x11 = int(int(i/2)*16/27)
   be130:    d346fd6b     lsr    x11, x11, #6                    // x11 = int(i/216)
   be134:    d2800d8c     mov    x12, #0x6c                      // x12 = 108
   be138:    9b0ba98a     msub    x10, x12, x11, x10             // x10 = 108*int(i/216)-int(i/2)=(i/2)%108
   be13c:    8b060884     add    x4, x4, x6, lsl #2              // x4 = (i/216)%20+20*int(i/(216*20*16))
   be140:    9b0c2884     madd    x4, x4, x12, x10               // x4 = 108*(((i/216)%20+20*int(i/(216*20*16))) + (i/2)%108
   be144:    91280084     add    x4, x4, #0xa00                  // x4 = 2560 + 108*(((i/216)%20+20*int(i/(216*20*16))) + (i/2)%108
   be148:    9140c884     add    x4, x4, #0x32, lsl #12          // x4 = 207360 + 108*(((i/216)%20+20*int(i/(216*20*16))) + (i/2)%108 = attribute byte array index
   be14c:    d2886a1b     mov    x27, #0x4350
   be150:    f2a0007b     movk    x27, #0x3, lsl #16             // x27 = 213840
   be154:    eb1b009f     cmp    x4, x27                         // check attribute byte address is not bigger than array
   be158:    540001a2     b.cs    5f                             // if so, jump forward
   be15c:    f9002be0     str    x0, [sp, #80]                   // store i in stack
   be160:    3900c3e9     strb    w9, [sp, #48]                  // store p in stack
   be164:    f90033e2     str    x2, [sp, #96]                   // store int(i/216) in stack
   be168:    910200e6     add    x6, x7, #0x80                   // x6 = (i/(216*20))%16 + 16*((i/216)%20) + 320*int(i/216*20*16) + 128 = y
   be16c:    f90027e6     str    x6, [sp, #72]                   // store y on stack
   be170:    38646904     ldrb    w4, [x8, x4]                   // w4 = byte at [sp + 15 double words + attribute byte array index] = attribute byte
   be174:    3900e3e4     strb    w4, [sp, #56]                  // store attribute byte on stack
   be178:    d2800007     mov    x7, #0x0                        // x7 = 0 (=a)
   be17c:    17ffffca     b    2b                                // jump back to 2:
4:
   be180:    f85f83fd     ldur    x29, [sp, #-8]                 // restore frame pointer
   be184:    f84707fe     ldr    x30, [sp], #112                 // restore link register
   be188:    d65f03c0     ret                                    // return
5:
   be18c:    97fde341     bl    36e90 <runtime.panicindex>       // trigger a runtime panic
   be190:    bea71700     .inst    0xbea71700 ; undefined
6:
   be194:    aa1e03e3     mov    x3, x30                         // increase stack size and jump back to start of method
   be198:    97fe838e     bl    5efd0 <runtime.morestack_noctxt>
   be19c:    17ffff61     b    bdf20 <github.com/petemoore/homescreen/screendump/lib.Render>
// LOOP FOREVER
7:
   be1a0:    14000000     b    7b                                // loop forever
   be1a4:    000343c8     .inst    0x000343c8 ; undefined
    ...
