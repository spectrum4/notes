
build/kernel8.elf:     file format elf64-littleaarch64


Disassembly of section .text.boot:

0000000000000000 <_start>:
   0:	d53800a0 	mrs	x0, mpidr_el1
   4:	92401c00 	and	x0, x0, #0xff
   8:	b4000060 	cbz	x0, 14 <master>
   c:	14000001 	b	10 <proc_hang>

0000000000000010 <proc_hang>:
  10:	14000000 	b	10 <proc_hang>

0000000000000014 <master>:
  14:	58000260 	ldr	x0, 60 <el1_entry+0x20>
  18:	d5181000 	msr	sctlr_el1, x0
  1c:	58000260 	ldr	x0, 68 <el1_entry+0x28>
  20:	d51c1100 	msr	hcr_el2, x0
  24:	58000260 	ldr	x0, 70 <el1_entry+0x30>
  28:	d51e1100 	msr	scr_el3, x0
  2c:	58000260 	ldr	x0, 78 <el1_entry+0x38>
  30:	d51e4000 	msr	spsr_el3, x0
  34:	10000060 	adr	x0, 40 <el1_entry>
  38:	d51e4020 	msr	elr_el3, x0
  3c:	d69f03e0 	eret

0000000000000040 <el1_entry>:
  40:	10006380 	adr	x0, cb0 <bss_begin>
  44:	100063e1 	adr	x1, cc0 <bss_end>
  48:	cb000021 	sub	x1, x1, x0
  4c:	9400030e 	bl	c84 <memzero>
  50:	b26a03ff 	mov	sp, #0x400000              	// #4194304
  54:	940002f0 	bl	c14 <kernel_main>
  58:	17ffffee 	b	10 <proc_hang>
  5c:	00000000 	.word	0x00000000
  60:	30d00800 	.word	0x30d00800
  64:	00000000 	.word	0x00000000
  68:	80000000 	.word	0x80000000
  6c:	00000000 	.word	0x00000000
  70:	00000431 	.word	0x00000431
  74:	00000000 	.word	0x00000000
  78:	000001c5 	.word	0x000001c5
  7c:	00000000 	.word	0x00000000

Disassembly of section .text:

0000000000000080 <uart_send>:
  80:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
  84:	910003fd 	mov	x29, sp
  88:	39007fa0 	strb	w0, [x29, #31]
  8c:	d28a0a80 	mov	x0, #0x5054                	// #20564
  90:	f2a7e420 	movk	x0, #0x3f21, lsl #16
  94:	940002f7 	bl	c70 <get32>
  98:	121b0000 	and	w0, w0, #0x20
  9c:	7100001f 	cmp	w0, #0x0
  a0:	54000041 	b.ne	a8 <uart_send+0x28>  // b.any
  a4:	17fffffa 	b	8c <uart_send+0xc>
  a8:	d503201f 	nop
  ac:	39407fa0 	ldrb	w0, [x29, #31]
  b0:	2a0003e1 	mov	w1, w0
  b4:	d28a0800 	mov	x0, #0x5040                	// #20544
  b8:	f2a7e420 	movk	x0, #0x3f21, lsl #16
  bc:	940002eb 	bl	c68 <put32>
  c0:	d503201f 	nop
  c4:	a8c27bfd 	ldp	x29, x30, [sp], #32
  c8:	d65f03c0 	ret

00000000000000cc <uart_recv>:
  cc:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
  d0:	910003fd 	mov	x29, sp
  d4:	d28a0a80 	mov	x0, #0x5054                	// #20564
  d8:	f2a7e420 	movk	x0, #0x3f21, lsl #16
  dc:	940002e5 	bl	c70 <get32>
  e0:	12000000 	and	w0, w0, #0x1
  e4:	7100001f 	cmp	w0, #0x0
  e8:	54000041 	b.ne	f0 <uart_recv+0x24>  // b.any
  ec:	17fffffa 	b	d4 <uart_recv+0x8>
  f0:	d503201f 	nop
  f4:	d28a0800 	mov	x0, #0x5040                	// #20544
  f8:	f2a7e420 	movk	x0, #0x3f21, lsl #16
  fc:	940002dd 	bl	c70 <get32>
 100:	53001c00 	uxtb	w0, w0
 104:	a8c17bfd 	ldp	x29, x30, [sp], #16
 108:	d65f03c0 	ret

000000000000010c <uart_send_string>:
 10c:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
 110:	910003fd 	mov	x29, sp
 114:	f9000fa0 	str	x0, [x29, #24]
 118:	b9002fbf 	str	wzr, [x29, #44]
 11c:	14000009 	b	140 <uart_send_string+0x34>
 120:	b9802fa0 	ldrsw	x0, [x29, #44]
 124:	f9400fa1 	ldr	x1, [x29, #24]
 128:	8b000020 	add	x0, x1, x0
 12c:	39400000 	ldrb	w0, [x0]
 130:	97ffffd4 	bl	80 <uart_send>
 134:	b9402fa0 	ldr	w0, [x29, #44]
 138:	11000400 	add	w0, w0, #0x1
 13c:	b9002fa0 	str	w0, [x29, #44]
 140:	b9802fa0 	ldrsw	x0, [x29, #44]
 144:	f9400fa1 	ldr	x1, [x29, #24]
 148:	8b000020 	add	x0, x1, x0
 14c:	39400000 	ldrb	w0, [x0]
 150:	7100001f 	cmp	w0, #0x0
 154:	54fffe61 	b.ne	120 <uart_send_string+0x14>  // b.any
 158:	d503201f 	nop
 15c:	a8c37bfd 	ldp	x29, x30, [sp], #48
 160:	d65f03c0 	ret

0000000000000164 <uart_init>:
 164:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
 168:	910003fd 	mov	x29, sp
 16c:	d2800080 	mov	x0, #0x4                   	// #4
 170:	f2a7e400 	movk	x0, #0x3f20, lsl #16
 174:	940002bf 	bl	c70 <get32>
 178:	b9001fa0 	str	w0, [x29, #28]
 17c:	b9401fa0 	ldr	w0, [x29, #28]
 180:	12117000 	and	w0, w0, #0xffff8fff
 184:	b9001fa0 	str	w0, [x29, #28]
 188:	b9401fa0 	ldr	w0, [x29, #28]
 18c:	32130000 	orr	w0, w0, #0x2000
 190:	b9001fa0 	str	w0, [x29, #28]
 194:	b9401fa0 	ldr	w0, [x29, #28]
 198:	120e7000 	and	w0, w0, #0xfffc7fff
 19c:	b9001fa0 	str	w0, [x29, #28]
 1a0:	b9401fa0 	ldr	w0, [x29, #28]
 1a4:	32100000 	orr	w0, w0, #0x10000
 1a8:	b9001fa0 	str	w0, [x29, #28]
 1ac:	b9401fa1 	ldr	w1, [x29, #28]
 1b0:	d2800080 	mov	x0, #0x4                   	// #4
 1b4:	f2a7e400 	movk	x0, #0x3f20, lsl #16
 1b8:	940002ac 	bl	c68 <put32>
 1bc:	52800001 	mov	w1, #0x0                   	// #0
 1c0:	d2801280 	mov	x0, #0x94                  	// #148
 1c4:	f2a7e400 	movk	x0, #0x3f20, lsl #16
 1c8:	940002a8 	bl	c68 <put32>
 1cc:	d28012c0 	mov	x0, #0x96                  	// #150
 1d0:	940002aa 	bl	c78 <delay>
 1d4:	52980001 	mov	w1, #0xc000                	// #49152
 1d8:	d2801300 	mov	x0, #0x98                  	// #152
 1dc:	f2a7e400 	movk	x0, #0x3f20, lsl #16
 1e0:	940002a2 	bl	c68 <put32>
 1e4:	d28012c0 	mov	x0, #0x96                  	// #150
 1e8:	940002a4 	bl	c78 <delay>
 1ec:	52800001 	mov	w1, #0x0                   	// #0
 1f0:	d2801300 	mov	x0, #0x98                  	// #152
 1f4:	f2a7e400 	movk	x0, #0x3f20, lsl #16
 1f8:	9400029c 	bl	c68 <put32>
 1fc:	52800021 	mov	w1, #0x1                   	// #1
 200:	d28a0080 	mov	x0, #0x5004                	// #20484
 204:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 208:	94000298 	bl	c68 <put32>
 20c:	52800001 	mov	w1, #0x0                   	// #0
 210:	d28a0c00 	mov	x0, #0x5060                	// #20576
 214:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 218:	94000294 	bl	c68 <put32>
 21c:	52800001 	mov	w1, #0x0                   	// #0
 220:	d28a0880 	mov	x0, #0x5044                	// #20548
 224:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 228:	94000290 	bl	c68 <put32>
 22c:	52800061 	mov	w1, #0x3                   	// #3
 230:	d28a0980 	mov	x0, #0x504c                	// #20556
 234:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 238:	9400028c 	bl	c68 <put32>
 23c:	52800001 	mov	w1, #0x0                   	// #0
 240:	d28a0a00 	mov	x0, #0x5050                	// #20560
 244:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 248:	94000288 	bl	c68 <put32>
 24c:	528021c1 	mov	w1, #0x10e                 	// #270
 250:	d28a0d00 	mov	x0, #0x5068                	// #20584
 254:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 258:	94000284 	bl	c68 <put32>
 25c:	52800061 	mov	w1, #0x3                   	// #3
 260:	d28a0c00 	mov	x0, #0x5060                	// #20576
 264:	f2a7e420 	movk	x0, #0x3f21, lsl #16
 268:	94000280 	bl	c68 <put32>
 26c:	d503201f 	nop
 270:	a8c27bfd 	ldp	x29, x30, [sp], #32
 274:	d65f03c0 	ret

0000000000000278 <putc>:
 278:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
 27c:	910003fd 	mov	x29, sp
 280:	f9000fa0 	str	x0, [x29, #24]
 284:	39005fa1 	strb	w1, [x29, #23]
 288:	39405fa0 	ldrb	w0, [x29, #23]
 28c:	97ffff7d 	bl	80 <uart_send>
 290:	d503201f 	nop
 294:	a8c27bfd 	ldp	x29, x30, [sp], #32
 298:	d65f03c0 	ret

000000000000029c <ui2a>:
 29c:	d100c3ff 	sub	sp, sp, #0x30
 2a0:	b9001fe0 	str	w0, [sp, #28]
 2a4:	b9001be1 	str	w1, [sp, #24]
 2a8:	b90017e2 	str	w2, [sp, #20]
 2ac:	f90007e3 	str	x3, [sp, #8]
 2b0:	b9002fff 	str	wzr, [sp, #44]
 2b4:	52800020 	mov	w0, #0x1                   	// #1
 2b8:	b9002be0 	str	w0, [sp, #40]
 2bc:	14000005 	b	2d0 <ui2a+0x34>
 2c0:	b9402be1 	ldr	w1, [sp, #40]
 2c4:	b9401be0 	ldr	w0, [sp, #24]
 2c8:	1b007c20 	mul	w0, w1, w0
 2cc:	b9002be0 	str	w0, [sp, #40]
 2d0:	b9401fe1 	ldr	w1, [sp, #28]
 2d4:	b9402be0 	ldr	w0, [sp, #40]
 2d8:	1ac00821 	udiv	w1, w1, w0
 2dc:	b9401be0 	ldr	w0, [sp, #24]
 2e0:	6b00003f 	cmp	w1, w0
 2e4:	54fffee2 	b.cs	2c0 <ui2a+0x24>  // b.hs, b.nlast
 2e8:	1400002f 	b	3a4 <ui2a+0x108>
 2ec:	b9401fe1 	ldr	w1, [sp, #28]
 2f0:	b9402be0 	ldr	w0, [sp, #40]
 2f4:	1ac00820 	udiv	w0, w1, w0
 2f8:	b90027e0 	str	w0, [sp, #36]
 2fc:	b9401fe0 	ldr	w0, [sp, #28]
 300:	b9402be1 	ldr	w1, [sp, #40]
 304:	1ac10802 	udiv	w2, w0, w1
 308:	b9402be1 	ldr	w1, [sp, #40]
 30c:	1b017c41 	mul	w1, w2, w1
 310:	4b010000 	sub	w0, w0, w1
 314:	b9001fe0 	str	w0, [sp, #28]
 318:	b9402be1 	ldr	w1, [sp, #40]
 31c:	b9401be0 	ldr	w0, [sp, #24]
 320:	1ac00820 	udiv	w0, w1, w0
 324:	b9002be0 	str	w0, [sp, #40]
 328:	b9402fe0 	ldr	w0, [sp, #44]
 32c:	7100001f 	cmp	w0, #0x0
 330:	540000e1 	b.ne	34c <ui2a+0xb0>  // b.any
 334:	b94027e0 	ldr	w0, [sp, #36]
 338:	7100001f 	cmp	w0, #0x0
 33c:	5400008c 	b.gt	34c <ui2a+0xb0>
 340:	b9402be0 	ldr	w0, [sp, #40]
 344:	7100001f 	cmp	w0, #0x0
 348:	540002e1 	b.ne	3a4 <ui2a+0x108>  // b.any
 34c:	f94007e1 	ldr	x1, [sp, #8]
 350:	91000420 	add	x0, x1, #0x1
 354:	f90007e0 	str	x0, [sp, #8]
 358:	b94027e0 	ldr	w0, [sp, #36]
 35c:	7100241f 	cmp	w0, #0x9
 360:	5400010d 	b.le	380 <ui2a+0xe4>
 364:	b94017e0 	ldr	w0, [sp, #20]
 368:	7100001f 	cmp	w0, #0x0
 36c:	54000060 	b.eq	378 <ui2a+0xdc>  // b.none
 370:	528006e0 	mov	w0, #0x37                  	// #55
 374:	14000004 	b	384 <ui2a+0xe8>
 378:	52800ae0 	mov	w0, #0x57                  	// #87
 37c:	14000002 	b	384 <ui2a+0xe8>
 380:	52800600 	mov	w0, #0x30                  	// #48
 384:	b94027e2 	ldr	w2, [sp, #36]
 388:	53001c42 	uxtb	w2, w2
 38c:	0b020000 	add	w0, w0, w2
 390:	53001c00 	uxtb	w0, w0
 394:	39000020 	strb	w0, [x1]
 398:	b9402fe0 	ldr	w0, [sp, #44]
 39c:	11000400 	add	w0, w0, #0x1
 3a0:	b9002fe0 	str	w0, [sp, #44]
 3a4:	b9402be0 	ldr	w0, [sp, #40]
 3a8:	7100001f 	cmp	w0, #0x0
 3ac:	54fffa01 	b.ne	2ec <ui2a+0x50>  // b.any
 3b0:	f94007e0 	ldr	x0, [sp, #8]
 3b4:	3900001f 	strb	wzr, [x0]
 3b8:	d503201f 	nop
 3bc:	9100c3ff 	add	sp, sp, #0x30
 3c0:	d65f03c0 	ret

00000000000003c4 <i2a>:
 3c4:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
 3c8:	910003fd 	mov	x29, sp
 3cc:	b9001fa0 	str	w0, [x29, #28]
 3d0:	f9000ba1 	str	x1, [x29, #16]
 3d4:	b9401fa0 	ldr	w0, [x29, #28]
 3d8:	7100001f 	cmp	w0, #0x0
 3dc:	5400012a 	b.ge	400 <i2a+0x3c>  // b.tcont
 3e0:	b9401fa0 	ldr	w0, [x29, #28]
 3e4:	4b0003e0 	neg	w0, w0
 3e8:	b9001fa0 	str	w0, [x29, #28]
 3ec:	f9400ba0 	ldr	x0, [x29, #16]
 3f0:	91000401 	add	x1, x0, #0x1
 3f4:	f9000ba1 	str	x1, [x29, #16]
 3f8:	528005a1 	mov	w1, #0x2d                  	// #45
 3fc:	39000001 	strb	w1, [x0]
 400:	b9401fa0 	ldr	w0, [x29, #28]
 404:	f9400ba3 	ldr	x3, [x29, #16]
 408:	52800002 	mov	w2, #0x0                   	// #0
 40c:	52800141 	mov	w1, #0xa                   	// #10
 410:	97ffffa3 	bl	29c <ui2a>
 414:	d503201f 	nop
 418:	a8c27bfd 	ldp	x29, x30, [sp], #32
 41c:	d65f03c0 	ret

0000000000000420 <a2d>:
 420:	d10043ff 	sub	sp, sp, #0x10
 424:	39003fe0 	strb	w0, [sp, #15]
 428:	39403fe0 	ldrb	w0, [sp, #15]
 42c:	7100bc1f 	cmp	w0, #0x2f
 430:	540000e9 	b.ls	44c <a2d+0x2c>  // b.plast
 434:	39403fe0 	ldrb	w0, [sp, #15]
 438:	7100e41f 	cmp	w0, #0x39
 43c:	54000088 	b.hi	44c <a2d+0x2c>  // b.pmore
 440:	39403fe0 	ldrb	w0, [sp, #15]
 444:	5100c000 	sub	w0, w0, #0x30
 448:	14000014 	b	498 <a2d+0x78>
 44c:	39403fe0 	ldrb	w0, [sp, #15]
 450:	7101801f 	cmp	w0, #0x60
 454:	540000e9 	b.ls	470 <a2d+0x50>  // b.plast
 458:	39403fe0 	ldrb	w0, [sp, #15]
 45c:	7101981f 	cmp	w0, #0x66
 460:	54000088 	b.hi	470 <a2d+0x50>  // b.pmore
 464:	39403fe0 	ldrb	w0, [sp, #15]
 468:	51015c00 	sub	w0, w0, #0x57
 46c:	1400000b 	b	498 <a2d+0x78>
 470:	39403fe0 	ldrb	w0, [sp, #15]
 474:	7101001f 	cmp	w0, #0x40
 478:	540000e9 	b.ls	494 <a2d+0x74>  // b.plast
 47c:	39403fe0 	ldrb	w0, [sp, #15]
 480:	7101181f 	cmp	w0, #0x46
 484:	54000088 	b.hi	494 <a2d+0x74>  // b.pmore
 488:	39403fe0 	ldrb	w0, [sp, #15]
 48c:	5100dc00 	sub	w0, w0, #0x37
 490:	14000002 	b	498 <a2d+0x78>
 494:	12800000 	mov	w0, #0xffffffff            	// #-1
 498:	910043ff 	add	sp, sp, #0x10
 49c:	d65f03c0 	ret

00000000000004a0 <a2i>:
 4a0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
 4a4:	910003fd 	mov	x29, sp
 4a8:	3900bfa0 	strb	w0, [x29, #47]
 4ac:	f90013a1 	str	x1, [x29, #32]
 4b0:	b9002ba2 	str	w2, [x29, #40]
 4b4:	f9000fa3 	str	x3, [x29, #24]
 4b8:	f94013a0 	ldr	x0, [x29, #32]
 4bc:	f9400000 	ldr	x0, [x0]
 4c0:	f9001fa0 	str	x0, [x29, #56]
 4c4:	b90037bf 	str	wzr, [x29, #52]
 4c8:	14000010 	b	508 <a2i+0x68>
 4cc:	b94033a1 	ldr	w1, [x29, #48]
 4d0:	b9402ba0 	ldr	w0, [x29, #40]
 4d4:	6b00003f 	cmp	w1, w0
 4d8:	5400026c 	b.gt	524 <a2i+0x84>
 4dc:	b94037a1 	ldr	w1, [x29, #52]
 4e0:	b9402ba0 	ldr	w0, [x29, #40]
 4e4:	1b007c21 	mul	w1, w1, w0
 4e8:	b94033a0 	ldr	w0, [x29, #48]
 4ec:	0b000020 	add	w0, w1, w0
 4f0:	b90037a0 	str	w0, [x29, #52]
 4f4:	f9401fa0 	ldr	x0, [x29, #56]
 4f8:	91000401 	add	x1, x0, #0x1
 4fc:	f9001fa1 	str	x1, [x29, #56]
 500:	39400000 	ldrb	w0, [x0]
 504:	3900bfa0 	strb	w0, [x29, #47]
 508:	3940bfa0 	ldrb	w0, [x29, #47]
 50c:	97ffffc5 	bl	420 <a2d>
 510:	b90033a0 	str	w0, [x29, #48]
 514:	b94033a0 	ldr	w0, [x29, #48]
 518:	7100001f 	cmp	w0, #0x0
 51c:	54fffd8a 	b.ge	4cc <a2i+0x2c>  // b.tcont
 520:	14000002 	b	528 <a2i+0x88>
 524:	d503201f 	nop
 528:	f94013a0 	ldr	x0, [x29, #32]
 52c:	f9401fa1 	ldr	x1, [x29, #56]
 530:	f9000001 	str	x1, [x0]
 534:	f9400fa0 	ldr	x0, [x29, #24]
 538:	b94037a1 	ldr	w1, [x29, #52]
 53c:	b9000001 	str	w1, [x0]
 540:	3940bfa0 	ldrb	w0, [x29, #47]
 544:	a8c47bfd 	ldp	x29, x30, [sp], #64
 548:	d65f03c0 	ret

000000000000054c <putchw>:
 54c:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
 550:	910003fd 	mov	x29, sp
 554:	f90017a0 	str	x0, [x29, #40]
 558:	f90013a1 	str	x1, [x29, #32]
 55c:	b9001fa2 	str	w2, [x29, #28]
 560:	39006fa3 	strb	w3, [x29, #27]
 564:	f9000ba4 	str	x4, [x29, #16]
 568:	39406fa0 	ldrb	w0, [x29, #27]
 56c:	7100001f 	cmp	w0, #0x0
 570:	54000060 	b.eq	57c <putchw+0x30>  // b.none
 574:	52800600 	mov	w0, #0x30                  	// #48
 578:	14000002 	b	580 <putchw+0x34>
 57c:	52800400 	mov	w0, #0x20                  	// #32
 580:	3900dfa0 	strb	w0, [x29, #55]
 584:	f9400ba0 	ldr	x0, [x29, #16]
 588:	f9001fa0 	str	x0, [x29, #56]
 58c:	14000004 	b	59c <putchw+0x50>
 590:	b9401fa0 	ldr	w0, [x29, #28]
 594:	51000400 	sub	w0, w0, #0x1
 598:	b9001fa0 	str	w0, [x29, #28]
 59c:	f9401fa0 	ldr	x0, [x29, #56]
 5a0:	91000401 	add	x1, x0, #0x1
 5a4:	f9001fa1 	str	x1, [x29, #56]
 5a8:	39400000 	ldrb	w0, [x0]
 5ac:	7100001f 	cmp	w0, #0x0
 5b0:	54000120 	b.eq	5d4 <putchw+0x88>  // b.none
 5b4:	b9401fa0 	ldr	w0, [x29, #28]
 5b8:	7100001f 	cmp	w0, #0x0
 5bc:	54fffeac 	b.gt	590 <putchw+0x44>
 5c0:	14000005 	b	5d4 <putchw+0x88>
 5c4:	f94013a2 	ldr	x2, [x29, #32]
 5c8:	3940dfa1 	ldrb	w1, [x29, #55]
 5cc:	f94017a0 	ldr	x0, [x29, #40]
 5d0:	d63f0040 	blr	x2
 5d4:	b9401fa0 	ldr	w0, [x29, #28]
 5d8:	51000401 	sub	w1, w0, #0x1
 5dc:	b9001fa1 	str	w1, [x29, #28]
 5e0:	7100001f 	cmp	w0, #0x0
 5e4:	54ffff0c 	b.gt	5c4 <putchw+0x78>
 5e8:	14000005 	b	5fc <putchw+0xb0>
 5ec:	f94013a2 	ldr	x2, [x29, #32]
 5f0:	3940dba1 	ldrb	w1, [x29, #54]
 5f4:	f94017a0 	ldr	x0, [x29, #40]
 5f8:	d63f0040 	blr	x2
 5fc:	f9400ba0 	ldr	x0, [x29, #16]
 600:	91000401 	add	x1, x0, #0x1
 604:	f9000ba1 	str	x1, [x29, #16]
 608:	39400000 	ldrb	w0, [x0]
 60c:	3900dba0 	strb	w0, [x29, #54]
 610:	3940dba0 	ldrb	w0, [x29, #54]
 614:	7100001f 	cmp	w0, #0x0
 618:	54fffea1 	b.ne	5ec <putchw+0xa0>  // b.any
 61c:	d503201f 	nop
 620:	a8c47bfd 	ldp	x29, x30, [sp], #64
 624:	d65f03c0 	ret

0000000000000628 <tfp_format>:
 628:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
 62c:	910003fd 	mov	x29, sp
 630:	f9000bf3 	str	x19, [sp, #16]
 634:	f9001fa0 	str	x0, [x29, #56]
 638:	f9001ba1 	str	x1, [x29, #48]
 63c:	f90017a2 	str	x2, [x29, #40]
 640:	aa0303f3 	mov	x19, x3
 644:	140000fd 	b	a38 <tfp_format+0x410>
 648:	39417fa0 	ldrb	w0, [x29, #95]
 64c:	7100941f 	cmp	w0, #0x25
 650:	540000c0 	b.eq	668 <tfp_format+0x40>  // b.none
 654:	f9401ba2 	ldr	x2, [x29, #48]
 658:	39417fa1 	ldrb	w1, [x29, #95]
 65c:	f9401fa0 	ldr	x0, [x29, #56]
 660:	d63f0040 	blr	x2
 664:	140000f5 	b	a38 <tfp_format+0x410>
 668:	39017bbf 	strb	wzr, [x29, #94]
 66c:	b9004fbf 	str	wzr, [x29, #76]
 670:	f94017a0 	ldr	x0, [x29, #40]
 674:	91000401 	add	x1, x0, #0x1
 678:	f90017a1 	str	x1, [x29, #40]
 67c:	39400000 	ldrb	w0, [x0]
 680:	39017fa0 	strb	w0, [x29, #95]
 684:	39417fa0 	ldrb	w0, [x29, #95]
 688:	7100c01f 	cmp	w0, #0x30
 68c:	54000101 	b.ne	6ac <tfp_format+0x84>  // b.any
 690:	f94017a0 	ldr	x0, [x29, #40]
 694:	91000401 	add	x1, x0, #0x1
 698:	f90017a1 	str	x1, [x29, #40]
 69c:	39400000 	ldrb	w0, [x0]
 6a0:	39017fa0 	strb	w0, [x29, #95]
 6a4:	52800020 	mov	w0, #0x1                   	// #1
 6a8:	39017ba0 	strb	w0, [x29, #94]
 6ac:	39417fa0 	ldrb	w0, [x29, #95]
 6b0:	7100bc1f 	cmp	w0, #0x2f
 6b4:	54000189 	b.ls	6e4 <tfp_format+0xbc>  // b.plast
 6b8:	39417fa0 	ldrb	w0, [x29, #95]
 6bc:	7100e41f 	cmp	w0, #0x39
 6c0:	54000128 	b.hi	6e4 <tfp_format+0xbc>  // b.pmore
 6c4:	910133a1 	add	x1, x29, #0x4c
 6c8:	9100a3a0 	add	x0, x29, #0x28
 6cc:	aa0103e3 	mov	x3, x1
 6d0:	52800142 	mov	w2, #0xa                   	// #10
 6d4:	aa0003e1 	mov	x1, x0
 6d8:	39417fa0 	ldrb	w0, [x29, #95]
 6dc:	97ffff71 	bl	4a0 <a2i>
 6e0:	39017fa0 	strb	w0, [x29, #95]
 6e4:	39417fa0 	ldrb	w0, [x29, #95]
 6e8:	71018c1f 	cmp	w0, #0x63
 6ec:	540011c0 	b.eq	924 <tfp_format+0x2fc>  // b.none
 6f0:	71018c1f 	cmp	w0, #0x63
 6f4:	5400010c 	b.gt	714 <tfp_format+0xec>
 6f8:	7100941f 	cmp	w0, #0x25
 6fc:	54001940 	b.eq	a24 <tfp_format+0x3fc>  // b.none
 700:	7101601f 	cmp	w0, #0x58
 704:	54000b60 	b.eq	870 <tfp_format+0x248>  // b.none
 708:	7100001f 	cmp	w0, #0x0
 70c:	54001a80 	b.eq	a5c <tfp_format+0x434>  // b.none
 710:	140000c9 	b	a34 <tfp_format+0x40c>
 714:	7101cc1f 	cmp	w0, #0x73
 718:	54001440 	b.eq	9a0 <tfp_format+0x378>  // b.none
 71c:	7101cc1f 	cmp	w0, #0x73
 720:	5400008c 	b.gt	730 <tfp_format+0x108>
 724:	7101901f 	cmp	w0, #0x64
 728:	540005c0 	b.eq	7e0 <tfp_format+0x1b8>  // b.none
 72c:	140000c2 	b	a34 <tfp_format+0x40c>
 730:	7101d41f 	cmp	w0, #0x75
 734:	54000080 	b.eq	744 <tfp_format+0x11c>  // b.none
 738:	7101e01f 	cmp	w0, #0x78
 73c:	540009a0 	b.eq	870 <tfp_format+0x248>  // b.none
 740:	140000bd 	b	a34 <tfp_format+0x40c>
 744:	b9401a60 	ldr	w0, [x19, #24]
 748:	f9400261 	ldr	x1, [x19]
 74c:	7100001f 	cmp	w0, #0x0
 750:	540000eb 	b.lt	76c <tfp_format+0x144>  // b.tstop
 754:	aa0103e0 	mov	x0, x1
 758:	91002c00 	add	x0, x0, #0xb
 75c:	927df000 	and	x0, x0, #0xfffffffffffffff8
 760:	f9000260 	str	x0, [x19]
 764:	aa0103e0 	mov	x0, x1
 768:	1400000f 	b	7a4 <tfp_format+0x17c>
 76c:	11002002 	add	w2, w0, #0x8
 770:	b9001a62 	str	w2, [x19, #24]
 774:	b9401a62 	ldr	w2, [x19, #24]
 778:	7100005f 	cmp	w2, #0x0
 77c:	540000ed 	b.le	798 <tfp_format+0x170>
 780:	aa0103e0 	mov	x0, x1
 784:	91002c00 	add	x0, x0, #0xb
 788:	927df000 	and	x0, x0, #0xfffffffffffffff8
 78c:	f9000260 	str	x0, [x19]
 790:	aa0103e0 	mov	x0, x1
 794:	14000004 	b	7a4 <tfp_format+0x17c>
 798:	f9400661 	ldr	x1, [x19, #8]
 79c:	93407c00 	sxtw	x0, w0
 7a0:	8b000020 	add	x0, x1, x0
 7a4:	b9400000 	ldr	w0, [x0]
 7a8:	910143a1 	add	x1, x29, #0x50
 7ac:	aa0103e3 	mov	x3, x1
 7b0:	52800002 	mov	w2, #0x0                   	// #0
 7b4:	52800141 	mov	w1, #0xa                   	// #10
 7b8:	97fffeb9 	bl	29c <ui2a>
 7bc:	b9404fa0 	ldr	w0, [x29, #76]
 7c0:	910143a1 	add	x1, x29, #0x50
 7c4:	aa0103e4 	mov	x4, x1
 7c8:	39417ba3 	ldrb	w3, [x29, #94]
 7cc:	2a0003e2 	mov	w2, w0
 7d0:	f9401ba1 	ldr	x1, [x29, #48]
 7d4:	f9401fa0 	ldr	x0, [x29, #56]
 7d8:	97ffff5d 	bl	54c <putchw>
 7dc:	14000097 	b	a38 <tfp_format+0x410>
 7e0:	b9401a60 	ldr	w0, [x19, #24]
 7e4:	f9400261 	ldr	x1, [x19]
 7e8:	7100001f 	cmp	w0, #0x0
 7ec:	540000eb 	b.lt	808 <tfp_format+0x1e0>  // b.tstop
 7f0:	aa0103e0 	mov	x0, x1
 7f4:	91002c00 	add	x0, x0, #0xb
 7f8:	927df000 	and	x0, x0, #0xfffffffffffffff8
 7fc:	f9000260 	str	x0, [x19]
 800:	aa0103e0 	mov	x0, x1
 804:	1400000f 	b	840 <tfp_format+0x218>
 808:	11002002 	add	w2, w0, #0x8
 80c:	b9001a62 	str	w2, [x19, #24]
 810:	b9401a62 	ldr	w2, [x19, #24]
 814:	7100005f 	cmp	w2, #0x0
 818:	540000ed 	b.le	834 <tfp_format+0x20c>
 81c:	aa0103e0 	mov	x0, x1
 820:	91002c00 	add	x0, x0, #0xb
 824:	927df000 	and	x0, x0, #0xfffffffffffffff8
 828:	f9000260 	str	x0, [x19]
 82c:	aa0103e0 	mov	x0, x1
 830:	14000004 	b	840 <tfp_format+0x218>
 834:	f9400661 	ldr	x1, [x19, #8]
 838:	93407c00 	sxtw	x0, w0
 83c:	8b000020 	add	x0, x1, x0
 840:	b9400000 	ldr	w0, [x0]
 844:	910143a1 	add	x1, x29, #0x50
 848:	97fffedf 	bl	3c4 <i2a>
 84c:	b9404fa0 	ldr	w0, [x29, #76]
 850:	910143a1 	add	x1, x29, #0x50
 854:	aa0103e4 	mov	x4, x1
 858:	39417ba3 	ldrb	w3, [x29, #94]
 85c:	2a0003e2 	mov	w2, w0
 860:	f9401ba1 	ldr	x1, [x29, #48]
 864:	f9401fa0 	ldr	x0, [x29, #56]
 868:	97ffff39 	bl	54c <putchw>
 86c:	14000073 	b	a38 <tfp_format+0x410>
 870:	b9401a60 	ldr	w0, [x19, #24]
 874:	f9400261 	ldr	x1, [x19]
 878:	7100001f 	cmp	w0, #0x0
 87c:	540000eb 	b.lt	898 <tfp_format+0x270>  // b.tstop
 880:	aa0103e0 	mov	x0, x1
 884:	91002c00 	add	x0, x0, #0xb
 888:	927df000 	and	x0, x0, #0xfffffffffffffff8
 88c:	f9000260 	str	x0, [x19]
 890:	aa0103e0 	mov	x0, x1
 894:	1400000f 	b	8d0 <tfp_format+0x2a8>
 898:	11002002 	add	w2, w0, #0x8
 89c:	b9001a62 	str	w2, [x19, #24]
 8a0:	b9401a62 	ldr	w2, [x19, #24]
 8a4:	7100005f 	cmp	w2, #0x0
 8a8:	540000ed 	b.le	8c4 <tfp_format+0x29c>
 8ac:	aa0103e0 	mov	x0, x1
 8b0:	91002c00 	add	x0, x0, #0xb
 8b4:	927df000 	and	x0, x0, #0xfffffffffffffff8
 8b8:	f9000260 	str	x0, [x19]
 8bc:	aa0103e0 	mov	x0, x1
 8c0:	14000004 	b	8d0 <tfp_format+0x2a8>
 8c4:	f9400661 	ldr	x1, [x19, #8]
 8c8:	93407c00 	sxtw	x0, w0
 8cc:	8b000020 	add	x0, x1, x0
 8d0:	b9400004 	ldr	w4, [x0]
 8d4:	39417fa0 	ldrb	w0, [x29, #95]
 8d8:	7101601f 	cmp	w0, #0x58
 8dc:	1a9f17e0 	cset	w0, eq  // eq = none
 8e0:	53001c00 	uxtb	w0, w0
 8e4:	2a0003e1 	mov	w1, w0
 8e8:	910143a0 	add	x0, x29, #0x50
 8ec:	aa0003e3 	mov	x3, x0
 8f0:	2a0103e2 	mov	w2, w1
 8f4:	52800201 	mov	w1, #0x10                  	// #16
 8f8:	2a0403e0 	mov	w0, w4
 8fc:	97fffe68 	bl	29c <ui2a>
 900:	b9404fa0 	ldr	w0, [x29, #76]
 904:	910143a1 	add	x1, x29, #0x50
 908:	aa0103e4 	mov	x4, x1
 90c:	39417ba3 	ldrb	w3, [x29, #94]
 910:	2a0003e2 	mov	w2, w0
 914:	f9401ba1 	ldr	x1, [x29, #48]
 918:	f9401fa0 	ldr	x0, [x29, #56]
 91c:	97ffff0c 	bl	54c <putchw>
 920:	14000046 	b	a38 <tfp_format+0x410>
 924:	b9401a60 	ldr	w0, [x19, #24]
 928:	f9400261 	ldr	x1, [x19]
 92c:	7100001f 	cmp	w0, #0x0
 930:	540000eb 	b.lt	94c <tfp_format+0x324>  // b.tstop
 934:	aa0103e0 	mov	x0, x1
 938:	91002c00 	add	x0, x0, #0xb
 93c:	927df000 	and	x0, x0, #0xfffffffffffffff8
 940:	f9000260 	str	x0, [x19]
 944:	aa0103e0 	mov	x0, x1
 948:	1400000f 	b	984 <tfp_format+0x35c>
 94c:	11002002 	add	w2, w0, #0x8
 950:	b9001a62 	str	w2, [x19, #24]
 954:	b9401a62 	ldr	w2, [x19, #24]
 958:	7100005f 	cmp	w2, #0x0
 95c:	540000ed 	b.le	978 <tfp_format+0x350>
 960:	aa0103e0 	mov	x0, x1
 964:	91002c00 	add	x0, x0, #0xb
 968:	927df000 	and	x0, x0, #0xfffffffffffffff8
 96c:	f9000260 	str	x0, [x19]
 970:	aa0103e0 	mov	x0, x1
 974:	14000004 	b	984 <tfp_format+0x35c>
 978:	f9400661 	ldr	x1, [x19, #8]
 97c:	93407c00 	sxtw	x0, w0
 980:	8b000020 	add	x0, x1, x0
 984:	b9400000 	ldr	w0, [x0]
 988:	53001c00 	uxtb	w0, w0
 98c:	f9401ba2 	ldr	x2, [x29, #48]
 990:	2a0003e1 	mov	w1, w0
 994:	f9401fa0 	ldr	x0, [x29, #56]
 998:	d63f0040 	blr	x2
 99c:	14000027 	b	a38 <tfp_format+0x410>
 9a0:	b9404fa5 	ldr	w5, [x29, #76]
 9a4:	b9401a60 	ldr	w0, [x19, #24]
 9a8:	f9400261 	ldr	x1, [x19]
 9ac:	7100001f 	cmp	w0, #0x0
 9b0:	540000eb 	b.lt	9cc <tfp_format+0x3a4>  // b.tstop
 9b4:	aa0103e0 	mov	x0, x1
 9b8:	91003c00 	add	x0, x0, #0xf
 9bc:	927df000 	and	x0, x0, #0xfffffffffffffff8
 9c0:	f9000260 	str	x0, [x19]
 9c4:	aa0103e0 	mov	x0, x1
 9c8:	1400000f 	b	a04 <tfp_format+0x3dc>
 9cc:	11002002 	add	w2, w0, #0x8
 9d0:	b9001a62 	str	w2, [x19, #24]
 9d4:	b9401a62 	ldr	w2, [x19, #24]
 9d8:	7100005f 	cmp	w2, #0x0
 9dc:	540000ed 	b.le	9f8 <tfp_format+0x3d0>
 9e0:	aa0103e0 	mov	x0, x1
 9e4:	91003c00 	add	x0, x0, #0xf
 9e8:	927df000 	and	x0, x0, #0xfffffffffffffff8
 9ec:	f9000260 	str	x0, [x19]
 9f0:	aa0103e0 	mov	x0, x1
 9f4:	14000004 	b	a04 <tfp_format+0x3dc>
 9f8:	f9400661 	ldr	x1, [x19, #8]
 9fc:	93407c00 	sxtw	x0, w0
 a00:	8b000020 	add	x0, x1, x0
 a04:	f9400000 	ldr	x0, [x0]
 a08:	aa0003e4 	mov	x4, x0
 a0c:	52800003 	mov	w3, #0x0                   	// #0
 a10:	2a0503e2 	mov	w2, w5
 a14:	f9401ba1 	ldr	x1, [x29, #48]
 a18:	f9401fa0 	ldr	x0, [x29, #56]
 a1c:	97fffecc 	bl	54c <putchw>
 a20:	14000006 	b	a38 <tfp_format+0x410>
 a24:	f9401ba2 	ldr	x2, [x29, #48]
 a28:	39417fa1 	ldrb	w1, [x29, #95]
 a2c:	f9401fa0 	ldr	x0, [x29, #56]
 a30:	d63f0040 	blr	x2
 a34:	d503201f 	nop
 a38:	f94017a0 	ldr	x0, [x29, #40]
 a3c:	91000401 	add	x1, x0, #0x1
 a40:	f90017a1 	str	x1, [x29, #40]
 a44:	39400000 	ldrb	w0, [x0]
 a48:	39017fa0 	strb	w0, [x29, #95]
 a4c:	39417fa0 	ldrb	w0, [x29, #95]
 a50:	7100001f 	cmp	w0, #0x0
 a54:	54ffdfa1 	b.ne	648 <tfp_format+0x20>  // b.any
 a58:	14000002 	b	a60 <tfp_format+0x438>
 a5c:	d503201f 	nop
 a60:	d503201f 	nop
 a64:	f9400bf3 	ldr	x19, [sp, #16]
 a68:	a8c67bfd 	ldp	x29, x30, [sp], #96
 a6c:	d65f03c0 	ret

0000000000000a70 <init_printf>:
 a70:	d10043ff 	sub	sp, sp, #0x10
 a74:	f90007e0 	str	x0, [sp, #8]
 a78:	f90003e1 	str	x1, [sp]
 a7c:	90000000 	adrp	x0, 0 <_start>
 a80:	9132c000 	add	x0, x0, #0xcb0
 a84:	f94003e1 	ldr	x1, [sp]
 a88:	f9000001 	str	x1, [x0]
 a8c:	90000000 	adrp	x0, 0 <_start>
 a90:	9132e000 	add	x0, x0, #0xcb8
 a94:	f94007e1 	ldr	x1, [sp, #8]
 a98:	f9000001 	str	x1, [x0]
 a9c:	d503201f 	nop
 aa0:	910043ff 	add	sp, sp, #0x10
 aa4:	d65f03c0 	ret

0000000000000aa8 <tfp_printf>:
 aa8:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
 aac:	910003fd 	mov	x29, sp
 ab0:	f9001fa0 	str	x0, [x29, #56]
 ab4:	f90037a1 	str	x1, [x29, #104]
 ab8:	f9003ba2 	str	x2, [x29, #112]
 abc:	f9003fa3 	str	x3, [x29, #120]
 ac0:	f90043a4 	str	x4, [x29, #128]
 ac4:	f90047a5 	str	x5, [x29, #136]
 ac8:	f9004ba6 	str	x6, [x29, #144]
 acc:	f9004fa7 	str	x7, [x29, #152]
 ad0:	910283a0 	add	x0, x29, #0xa0
 ad4:	f90023a0 	str	x0, [x29, #64]
 ad8:	910283a0 	add	x0, x29, #0xa0
 adc:	f90027a0 	str	x0, [x29, #72]
 ae0:	910183a0 	add	x0, x29, #0x60
 ae4:	f9002ba0 	str	x0, [x29, #80]
 ae8:	128006e0 	mov	w0, #0xffffffc8            	// #-56
 aec:	b9005ba0 	str	w0, [x29, #88]
 af0:	b9005fbf 	str	wzr, [x29, #92]
 af4:	90000000 	adrp	x0, 0 <_start>
 af8:	9132e000 	add	x0, x0, #0xcb8
 afc:	f9400004 	ldr	x4, [x0]
 b00:	90000000 	adrp	x0, 0 <_start>
 b04:	9132c000 	add	x0, x0, #0xcb0
 b08:	f9400005 	ldr	x5, [x0]
 b0c:	910043a2 	add	x2, x29, #0x10
 b10:	910103a3 	add	x3, x29, #0x40
 b14:	a9400460 	ldp	x0, x1, [x3]
 b18:	a9000440 	stp	x0, x1, [x2]
 b1c:	a9410460 	ldp	x0, x1, [x3, #16]
 b20:	a9010440 	stp	x0, x1, [x2, #16]
 b24:	910043a0 	add	x0, x29, #0x10
 b28:	aa0003e3 	mov	x3, x0
 b2c:	f9401fa2 	ldr	x2, [x29, #56]
 b30:	aa0503e1 	mov	x1, x5
 b34:	aa0403e0 	mov	x0, x4
 b38:	97fffebc 	bl	628 <tfp_format>
 b3c:	d503201f 	nop
 b40:	a8ca7bfd 	ldp	x29, x30, [sp], #160
 b44:	d65f03c0 	ret

0000000000000b48 <putcp>:
 b48:	d10043ff 	sub	sp, sp, #0x10
 b4c:	f90007e0 	str	x0, [sp, #8]
 b50:	39001fe1 	strb	w1, [sp, #7]
 b54:	f94007e0 	ldr	x0, [sp, #8]
 b58:	f9400000 	ldr	x0, [x0]
 b5c:	91000402 	add	x2, x0, #0x1
 b60:	f94007e1 	ldr	x1, [sp, #8]
 b64:	f9000022 	str	x2, [x1]
 b68:	39401fe1 	ldrb	w1, [sp, #7]
 b6c:	39000001 	strb	w1, [x0]
 b70:	d503201f 	nop
 b74:	910043ff 	add	sp, sp, #0x10
 b78:	d65f03c0 	ret

0000000000000b7c <tfp_sprintf>:
 b7c:	a9b77bfd 	stp	x29, x30, [sp, #-144]!
 b80:	910003fd 	mov	x29, sp
 b84:	f9001fa0 	str	x0, [x29, #56]
 b88:	f9001ba1 	str	x1, [x29, #48]
 b8c:	f90033a2 	str	x2, [x29, #96]
 b90:	f90037a3 	str	x3, [x29, #104]
 b94:	f9003ba4 	str	x4, [x29, #112]
 b98:	f9003fa5 	str	x5, [x29, #120]
 b9c:	f90043a6 	str	x6, [x29, #128]
 ba0:	f90047a7 	str	x7, [x29, #136]
 ba4:	910243a0 	add	x0, x29, #0x90
 ba8:	f90023a0 	str	x0, [x29, #64]
 bac:	910243a0 	add	x0, x29, #0x90
 bb0:	f90027a0 	str	x0, [x29, #72]
 bb4:	910183a0 	add	x0, x29, #0x60
 bb8:	f9002ba0 	str	x0, [x29, #80]
 bbc:	128005e0 	mov	w0, #0xffffffd0            	// #-48
 bc0:	b9005ba0 	str	w0, [x29, #88]
 bc4:	b9005fbf 	str	wzr, [x29, #92]
 bc8:	910043a2 	add	x2, x29, #0x10
 bcc:	910103a3 	add	x3, x29, #0x40
 bd0:	a9400460 	ldp	x0, x1, [x3]
 bd4:	a9000440 	stp	x0, x1, [x2]
 bd8:	a9410460 	ldp	x0, x1, [x3, #16]
 bdc:	a9010440 	stp	x0, x1, [x2, #16]
 be0:	910043a2 	add	x2, x29, #0x10
 be4:	90000000 	adrp	x0, 0 <_start>
 be8:	912d2001 	add	x1, x0, #0xb48
 bec:	9100e3a0 	add	x0, x29, #0x38
 bf0:	aa0203e3 	mov	x3, x2
 bf4:	f9401ba2 	ldr	x2, [x29, #48]
 bf8:	97fffe8c 	bl	628 <tfp_format>
 bfc:	9100e3a0 	add	x0, x29, #0x38
 c00:	52800001 	mov	w1, #0x0                   	// #0
 c04:	97ffffd1 	bl	b48 <putcp>
 c08:	d503201f 	nop
 c0c:	a8c97bfd 	ldp	x29, x30, [sp], #144
 c10:	d65f03c0 	ret

0000000000000c14 <kernel_main>:
 c14:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
 c18:	910003fd 	mov	x29, sp
 c1c:	97fffd52 	bl	164 <uart_init>
 c20:	90000000 	adrp	x0, 0 <_start>
 c24:	9109e000 	add	x0, x0, #0x278
 c28:	aa0003e1 	mov	x1, x0
 c2c:	d2800000 	mov	x0, #0x0                   	// #0
 c30:	97ffff90 	bl	a70 <init_printf>
 c34:	9400000a 	bl	c5c <get_el>
 c38:	b9001fa0 	str	w0, [x29, #28]
 c3c:	90000000 	adrp	x0, 0 <_start>
 c40:	91326000 	add	x0, x0, #0xc98
 c44:	b9401fa1 	ldr	w1, [x29, #28]
 c48:	97ffff98 	bl	aa8 <tfp_printf>
 c4c:	97fffd20 	bl	cc <uart_recv>
 c50:	53001c00 	uxtb	w0, w0
 c54:	97fffd0b 	bl	80 <uart_send>
 c58:	17fffffd 	b	c4c <kernel_main+0x38>

0000000000000c5c <get_el>:
 c5c:	d5384240 	mrs	x0, currentel
 c60:	d342fc00 	lsr	x0, x0, #2
 c64:	d65f03c0 	ret

0000000000000c68 <put32>:
 c68:	b9000001 	str	w1, [x0]
 c6c:	d65f03c0 	ret

0000000000000c70 <get32>:
 c70:	b9400000 	ldr	w0, [x0]
 c74:	d65f03c0 	ret

0000000000000c78 <delay>:
 c78:	f1000400 	subs	x0, x0, #0x1
 c7c:	54ffffe1 	b.ne	c78 <delay>  // b.any
 c80:	d65f03c0 	ret

0000000000000c84 <memzero>:
 c84:	f800841f 	str	xzr, [x0], #8
 c88:	f1002021 	subs	x1, x1, #0x8
 c8c:	54ffffcc 	b.gt	c84 <memzero>
 c90:	d65f03c0 	ret
