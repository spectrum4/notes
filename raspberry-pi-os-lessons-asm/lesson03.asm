
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
  40:	10013bc0 	adr	x0, 27b8 <bss_begin>
  44:	10013c41 	adr	x1, 27cc <bss_end>
  48:	cb000021 	sub	x1, x1, x0
  4c:	9400093d 	bl	2540 <memzero>
  50:	b26a03ff 	mov	sp, #0x400000              	// #4194304
  54:	940001eb 	bl	800 <kernel_main>
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

0000000000000800 <kernel_main>:
     800:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
     804:	910003fd 	mov	x29, sp
     808:	94000073 	bl	9d4 <uart_init>
     80c:	90000000 	adrp	x0, 0 <_start>
     810:	912ba000 	add	x0, x0, #0xae8
     814:	aa0003e1 	mov	x1, x0
     818:	d2800000 	mov	x0, #0x0                   	// #0
     81c:	940002b1 	bl	12e0 <init_printf>
     820:	9400035b 	bl	158c <irq_vector_init>
     824:	94000318 	bl	1484 <timer_init>
     828:	94000006 	bl	840 <enable_interrupt_controller>
     82c:	9400035b 	bl	1598 <enable_irq>
     830:	94000043 	bl	93c <uart_recv>
     834:	53001c00 	uxtb	w0, w0
     838:	9400002e 	bl	8f0 <uart_send>
     83c:	17fffffd 	b	830 <kernel_main+0x30>

0000000000000840 <enable_interrupt_controller>:
     840:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
     844:	910003fd 	mov	x29, sp
     848:	52800041 	mov	w1, #0x2                   	// #2
     84c:	d2964200 	mov	x0, #0xb210                	// #45584
     850:	f2a7e000 	movk	x0, #0x3f00, lsl #16
     854:	94000347 	bl	1570 <put32>
     858:	d503201f 	nop
     85c:	a8c17bfd 	ldp	x29, x30, [sp], #16
     860:	d65f03c0 	ret

0000000000000864 <show_invalid_entry_message>:
     864:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
     868:	910003fd 	mov	x29, sp
     86c:	b9002fa0 	str	w0, [x29, #44]
     870:	f90013a1 	str	x1, [x29, #32]
     874:	f9000fa2 	str	x2, [x29, #24]
     878:	d0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
     87c:	911ce000 	add	x0, x0, #0x738
     880:	b9802fa1 	ldrsw	x1, [x29, #44]
     884:	f8617801 	ldr	x1, [x0, x1, lsl #3]
     888:	d0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
     88c:	911b4000 	add	x0, x0, #0x6d0
     890:	f9400fa3 	ldr	x3, [x29, #24]
     894:	f94013a2 	ldr	x2, [x29, #32]
     898:	940002a0 	bl	1318 <tfp_printf>
     89c:	d503201f 	nop
     8a0:	a8c37bfd 	ldp	x29, x30, [sp], #48
     8a4:	d65f03c0 	ret

00000000000008a8 <handle_irq>:
     8a8:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
     8ac:	910003fd 	mov	x29, sp
     8b0:	d2964080 	mov	x0, #0xb204                	// #45572
     8b4:	f2a7e000 	movk	x0, #0x3f00, lsl #16
     8b8:	94000330 	bl	1578 <get32>
     8bc:	b9001fa0 	str	w0, [x29, #28]
     8c0:	b9401fa0 	ldr	w0, [x29, #28]
     8c4:	7100081f 	cmp	w0, #0x2
     8c8:	54000061 	b.ne	8d4 <handle_irq+0x2c>  // b.any
     8cc:	9400030a 	bl	14f4 <handle_timer_irq>
     8d0:	14000005 	b	8e4 <handle_irq+0x3c>
     8d4:	d0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
     8d8:	911bc000 	add	x0, x0, #0x6f0
     8dc:	b9401fa1 	ldr	w1, [x29, #28]
     8e0:	9400028e 	bl	1318 <tfp_printf>
     8e4:	d503201f 	nop
     8e8:	a8c27bfd 	ldp	x29, x30, [sp], #32
     8ec:	d65f03c0 	ret

00000000000008f0 <uart_send>:
     8f0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
     8f4:	910003fd 	mov	x29, sp
     8f8:	39007fa0 	strb	w0, [x29, #31]
     8fc:	d28a0a80 	mov	x0, #0x5054                	// #20564
     900:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     904:	9400031d 	bl	1578 <get32>
     908:	121b0000 	and	w0, w0, #0x20
     90c:	7100001f 	cmp	w0, #0x0
     910:	54000041 	b.ne	918 <uart_send+0x28>  // b.any
     914:	17fffffa 	b	8fc <uart_send+0xc>
     918:	d503201f 	nop
     91c:	39407fa0 	ldrb	w0, [x29, #31]
     920:	2a0003e1 	mov	w1, w0
     924:	d28a0800 	mov	x0, #0x5040                	// #20544
     928:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     92c:	94000311 	bl	1570 <put32>
     930:	d503201f 	nop
     934:	a8c27bfd 	ldp	x29, x30, [sp], #32
     938:	d65f03c0 	ret

000000000000093c <uart_recv>:
     93c:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
     940:	910003fd 	mov	x29, sp
     944:	d28a0a80 	mov	x0, #0x5054                	// #20564
     948:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     94c:	9400030b 	bl	1578 <get32>
     950:	12000000 	and	w0, w0, #0x1
     954:	7100001f 	cmp	w0, #0x0
     958:	54000041 	b.ne	960 <uart_recv+0x24>  // b.any
     95c:	17fffffa 	b	944 <uart_recv+0x8>
     960:	d503201f 	nop
     964:	d28a0800 	mov	x0, #0x5040                	// #20544
     968:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     96c:	94000303 	bl	1578 <get32>
     970:	53001c00 	uxtb	w0, w0
     974:	a8c17bfd 	ldp	x29, x30, [sp], #16
     978:	d65f03c0 	ret

000000000000097c <uart_send_string>:
     97c:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
     980:	910003fd 	mov	x29, sp
     984:	f9000fa0 	str	x0, [x29, #24]
     988:	b9002fbf 	str	wzr, [x29, #44]
     98c:	14000009 	b	9b0 <uart_send_string+0x34>
     990:	b9802fa0 	ldrsw	x0, [x29, #44]
     994:	f9400fa1 	ldr	x1, [x29, #24]
     998:	8b000020 	add	x0, x1, x0
     99c:	39400000 	ldrb	w0, [x0]
     9a0:	97ffffd4 	bl	8f0 <uart_send>
     9a4:	b9402fa0 	ldr	w0, [x29, #44]
     9a8:	11000400 	add	w0, w0, #0x1
     9ac:	b9002fa0 	str	w0, [x29, #44]
     9b0:	b9802fa0 	ldrsw	x0, [x29, #44]
     9b4:	f9400fa1 	ldr	x1, [x29, #24]
     9b8:	8b000020 	add	x0, x1, x0
     9bc:	39400000 	ldrb	w0, [x0]
     9c0:	7100001f 	cmp	w0, #0x0
     9c4:	54fffe61 	b.ne	990 <uart_send_string+0x14>  // b.any
     9c8:	d503201f 	nop
     9cc:	a8c37bfd 	ldp	x29, x30, [sp], #48
     9d0:	d65f03c0 	ret

00000000000009d4 <uart_init>:
     9d4:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
     9d8:	910003fd 	mov	x29, sp
     9dc:	d2800080 	mov	x0, #0x4                   	// #4
     9e0:	f2a7e400 	movk	x0, #0x3f20, lsl #16
     9e4:	940002e5 	bl	1578 <get32>
     9e8:	b9001fa0 	str	w0, [x29, #28]
     9ec:	b9401fa0 	ldr	w0, [x29, #28]
     9f0:	12117000 	and	w0, w0, #0xffff8fff
     9f4:	b9001fa0 	str	w0, [x29, #28]
     9f8:	b9401fa0 	ldr	w0, [x29, #28]
     9fc:	32130000 	orr	w0, w0, #0x2000
     a00:	b9001fa0 	str	w0, [x29, #28]
     a04:	b9401fa0 	ldr	w0, [x29, #28]
     a08:	120e7000 	and	w0, w0, #0xfffc7fff
     a0c:	b9001fa0 	str	w0, [x29, #28]
     a10:	b9401fa0 	ldr	w0, [x29, #28]
     a14:	32100000 	orr	w0, w0, #0x10000
     a18:	b9001fa0 	str	w0, [x29, #28]
     a1c:	b9401fa1 	ldr	w1, [x29, #28]
     a20:	d2800080 	mov	x0, #0x4                   	// #4
     a24:	f2a7e400 	movk	x0, #0x3f20, lsl #16
     a28:	940002d2 	bl	1570 <put32>
     a2c:	52800001 	mov	w1, #0x0                   	// #0
     a30:	d2801280 	mov	x0, #0x94                  	// #148
     a34:	f2a7e400 	movk	x0, #0x3f20, lsl #16
     a38:	940002ce 	bl	1570 <put32>
     a3c:	d28012c0 	mov	x0, #0x96                  	// #150
     a40:	940002d0 	bl	1580 <delay>
     a44:	52980001 	mov	w1, #0xc000                	// #49152
     a48:	d2801300 	mov	x0, #0x98                  	// #152
     a4c:	f2a7e400 	movk	x0, #0x3f20, lsl #16
     a50:	940002c8 	bl	1570 <put32>
     a54:	d28012c0 	mov	x0, #0x96                  	// #150
     a58:	940002ca 	bl	1580 <delay>
     a5c:	52800001 	mov	w1, #0x0                   	// #0
     a60:	d2801300 	mov	x0, #0x98                  	// #152
     a64:	f2a7e400 	movk	x0, #0x3f20, lsl #16
     a68:	940002c2 	bl	1570 <put32>
     a6c:	52800021 	mov	w1, #0x1                   	// #1
     a70:	d28a0080 	mov	x0, #0x5004                	// #20484
     a74:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     a78:	940002be 	bl	1570 <put32>
     a7c:	52800001 	mov	w1, #0x0                   	// #0
     a80:	d28a0c00 	mov	x0, #0x5060                	// #20576
     a84:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     a88:	940002ba 	bl	1570 <put32>
     a8c:	52800001 	mov	w1, #0x0                   	// #0
     a90:	d28a0880 	mov	x0, #0x5044                	// #20548
     a94:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     a98:	940002b6 	bl	1570 <put32>
     a9c:	52800061 	mov	w1, #0x3                   	// #3
     aa0:	d28a0980 	mov	x0, #0x504c                	// #20556
     aa4:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     aa8:	940002b2 	bl	1570 <put32>
     aac:	52800001 	mov	w1, #0x0                   	// #0
     ab0:	d28a0a00 	mov	x0, #0x5050                	// #20560
     ab4:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     ab8:	940002ae 	bl	1570 <put32>
     abc:	528021c1 	mov	w1, #0x10e                 	// #270
     ac0:	d28a0d00 	mov	x0, #0x5068                	// #20584
     ac4:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     ac8:	940002aa 	bl	1570 <put32>
     acc:	52800061 	mov	w1, #0x3                   	// #3
     ad0:	d28a0c00 	mov	x0, #0x5060                	// #20576
     ad4:	f2a7e420 	movk	x0, #0x3f21, lsl #16
     ad8:	940002a6 	bl	1570 <put32>
     adc:	d503201f 	nop
     ae0:	a8c27bfd 	ldp	x29, x30, [sp], #32
     ae4:	d65f03c0 	ret

0000000000000ae8 <putc>:
     ae8:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
     aec:	910003fd 	mov	x29, sp
     af0:	f9000fa0 	str	x0, [x29, #24]
     af4:	39005fa1 	strb	w1, [x29, #23]
     af8:	39405fa0 	ldrb	w0, [x29, #23]
     afc:	97ffff7d 	bl	8f0 <uart_send>
     b00:	d503201f 	nop
     b04:	a8c27bfd 	ldp	x29, x30, [sp], #32
     b08:	d65f03c0 	ret

0000000000000b0c <ui2a>:
     b0c:	d100c3ff 	sub	sp, sp, #0x30
     b10:	b9001fe0 	str	w0, [sp, #28]
     b14:	b9001be1 	str	w1, [sp, #24]
     b18:	b90017e2 	str	w2, [sp, #20]
     b1c:	f90007e3 	str	x3, [sp, #8]
     b20:	b9002fff 	str	wzr, [sp, #44]
     b24:	52800020 	mov	w0, #0x1                   	// #1
     b28:	b9002be0 	str	w0, [sp, #40]
     b2c:	14000005 	b	b40 <ui2a+0x34>
     b30:	b9402be1 	ldr	w1, [sp, #40]
     b34:	b9401be0 	ldr	w0, [sp, #24]
     b38:	1b007c20 	mul	w0, w1, w0
     b3c:	b9002be0 	str	w0, [sp, #40]
     b40:	b9401fe1 	ldr	w1, [sp, #28]
     b44:	b9402be0 	ldr	w0, [sp, #40]
     b48:	1ac00821 	udiv	w1, w1, w0
     b4c:	b9401be0 	ldr	w0, [sp, #24]
     b50:	6b00003f 	cmp	w1, w0
     b54:	54fffee2 	b.cs	b30 <ui2a+0x24>  // b.hs, b.nlast
     b58:	1400002f 	b	c14 <ui2a+0x108>
     b5c:	b9401fe1 	ldr	w1, [sp, #28]
     b60:	b9402be0 	ldr	w0, [sp, #40]
     b64:	1ac00820 	udiv	w0, w1, w0
     b68:	b90027e0 	str	w0, [sp, #36]
     b6c:	b9401fe0 	ldr	w0, [sp, #28]
     b70:	b9402be1 	ldr	w1, [sp, #40]
     b74:	1ac10802 	udiv	w2, w0, w1
     b78:	b9402be1 	ldr	w1, [sp, #40]
     b7c:	1b017c41 	mul	w1, w2, w1
     b80:	4b010000 	sub	w0, w0, w1
     b84:	b9001fe0 	str	w0, [sp, #28]
     b88:	b9402be1 	ldr	w1, [sp, #40]
     b8c:	b9401be0 	ldr	w0, [sp, #24]
     b90:	1ac00820 	udiv	w0, w1, w0
     b94:	b9002be0 	str	w0, [sp, #40]
     b98:	b9402fe0 	ldr	w0, [sp, #44]
     b9c:	7100001f 	cmp	w0, #0x0
     ba0:	540000e1 	b.ne	bbc <ui2a+0xb0>  // b.any
     ba4:	b94027e0 	ldr	w0, [sp, #36]
     ba8:	7100001f 	cmp	w0, #0x0
     bac:	5400008c 	b.gt	bbc <ui2a+0xb0>
     bb0:	b9402be0 	ldr	w0, [sp, #40]
     bb4:	7100001f 	cmp	w0, #0x0
     bb8:	540002e1 	b.ne	c14 <ui2a+0x108>  // b.any
     bbc:	f94007e1 	ldr	x1, [sp, #8]
     bc0:	91000420 	add	x0, x1, #0x1
     bc4:	f90007e0 	str	x0, [sp, #8]
     bc8:	b94027e0 	ldr	w0, [sp, #36]
     bcc:	7100241f 	cmp	w0, #0x9
     bd0:	5400010d 	b.le	bf0 <ui2a+0xe4>
     bd4:	b94017e0 	ldr	w0, [sp, #20]
     bd8:	7100001f 	cmp	w0, #0x0
     bdc:	54000060 	b.eq	be8 <ui2a+0xdc>  // b.none
     be0:	528006e0 	mov	w0, #0x37                  	// #55
     be4:	14000004 	b	bf4 <ui2a+0xe8>
     be8:	52800ae0 	mov	w0, #0x57                  	// #87
     bec:	14000002 	b	bf4 <ui2a+0xe8>
     bf0:	52800600 	mov	w0, #0x30                  	// #48
     bf4:	b94027e2 	ldr	w2, [sp, #36]
     bf8:	53001c42 	uxtb	w2, w2
     bfc:	0b020000 	add	w0, w0, w2
     c00:	53001c00 	uxtb	w0, w0
     c04:	39000020 	strb	w0, [x1]
     c08:	b9402fe0 	ldr	w0, [sp, #44]
     c0c:	11000400 	add	w0, w0, #0x1
     c10:	b9002fe0 	str	w0, [sp, #44]
     c14:	b9402be0 	ldr	w0, [sp, #40]
     c18:	7100001f 	cmp	w0, #0x0
     c1c:	54fffa01 	b.ne	b5c <ui2a+0x50>  // b.any
     c20:	f94007e0 	ldr	x0, [sp, #8]
     c24:	3900001f 	strb	wzr, [x0]
     c28:	d503201f 	nop
     c2c:	9100c3ff 	add	sp, sp, #0x30
     c30:	d65f03c0 	ret

0000000000000c34 <i2a>:
     c34:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
     c38:	910003fd 	mov	x29, sp
     c3c:	b9001fa0 	str	w0, [x29, #28]
     c40:	f9000ba1 	str	x1, [x29, #16]
     c44:	b9401fa0 	ldr	w0, [x29, #28]
     c48:	7100001f 	cmp	w0, #0x0
     c4c:	5400012a 	b.ge	c70 <i2a+0x3c>  // b.tcont
     c50:	b9401fa0 	ldr	w0, [x29, #28]
     c54:	4b0003e0 	neg	w0, w0
     c58:	b9001fa0 	str	w0, [x29, #28]
     c5c:	f9400ba0 	ldr	x0, [x29, #16]
     c60:	91000401 	add	x1, x0, #0x1
     c64:	f9000ba1 	str	x1, [x29, #16]
     c68:	528005a1 	mov	w1, #0x2d                  	// #45
     c6c:	39000001 	strb	w1, [x0]
     c70:	b9401fa0 	ldr	w0, [x29, #28]
     c74:	f9400ba3 	ldr	x3, [x29, #16]
     c78:	52800002 	mov	w2, #0x0                   	// #0
     c7c:	52800141 	mov	w1, #0xa                   	// #10
     c80:	97ffffa3 	bl	b0c <ui2a>
     c84:	d503201f 	nop
     c88:	a8c27bfd 	ldp	x29, x30, [sp], #32
     c8c:	d65f03c0 	ret

0000000000000c90 <a2d>:
     c90:	d10043ff 	sub	sp, sp, #0x10
     c94:	39003fe0 	strb	w0, [sp, #15]
     c98:	39403fe0 	ldrb	w0, [sp, #15]
     c9c:	7100bc1f 	cmp	w0, #0x2f
     ca0:	540000e9 	b.ls	cbc <a2d+0x2c>  // b.plast
     ca4:	39403fe0 	ldrb	w0, [sp, #15]
     ca8:	7100e41f 	cmp	w0, #0x39
     cac:	54000088 	b.hi	cbc <a2d+0x2c>  // b.pmore
     cb0:	39403fe0 	ldrb	w0, [sp, #15]
     cb4:	5100c000 	sub	w0, w0, #0x30
     cb8:	14000014 	b	d08 <a2d+0x78>
     cbc:	39403fe0 	ldrb	w0, [sp, #15]
     cc0:	7101801f 	cmp	w0, #0x60
     cc4:	540000e9 	b.ls	ce0 <a2d+0x50>  // b.plast
     cc8:	39403fe0 	ldrb	w0, [sp, #15]
     ccc:	7101981f 	cmp	w0, #0x66
     cd0:	54000088 	b.hi	ce0 <a2d+0x50>  // b.pmore
     cd4:	39403fe0 	ldrb	w0, [sp, #15]
     cd8:	51015c00 	sub	w0, w0, #0x57
     cdc:	1400000b 	b	d08 <a2d+0x78>
     ce0:	39403fe0 	ldrb	w0, [sp, #15]
     ce4:	7101001f 	cmp	w0, #0x40
     ce8:	540000e9 	b.ls	d04 <a2d+0x74>  // b.plast
     cec:	39403fe0 	ldrb	w0, [sp, #15]
     cf0:	7101181f 	cmp	w0, #0x46
     cf4:	54000088 	b.hi	d04 <a2d+0x74>  // b.pmore
     cf8:	39403fe0 	ldrb	w0, [sp, #15]
     cfc:	5100dc00 	sub	w0, w0, #0x37
     d00:	14000002 	b	d08 <a2d+0x78>
     d04:	12800000 	mov	w0, #0xffffffff            	// #-1
     d08:	910043ff 	add	sp, sp, #0x10
     d0c:	d65f03c0 	ret

0000000000000d10 <a2i>:
     d10:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
     d14:	910003fd 	mov	x29, sp
     d18:	3900bfa0 	strb	w0, [x29, #47]
     d1c:	f90013a1 	str	x1, [x29, #32]
     d20:	b9002ba2 	str	w2, [x29, #40]
     d24:	f9000fa3 	str	x3, [x29, #24]
     d28:	f94013a0 	ldr	x0, [x29, #32]
     d2c:	f9400000 	ldr	x0, [x0]
     d30:	f9001fa0 	str	x0, [x29, #56]
     d34:	b90037bf 	str	wzr, [x29, #52]
     d38:	14000010 	b	d78 <a2i+0x68>
     d3c:	b94033a1 	ldr	w1, [x29, #48]
     d40:	b9402ba0 	ldr	w0, [x29, #40]
     d44:	6b00003f 	cmp	w1, w0
     d48:	5400026c 	b.gt	d94 <a2i+0x84>
     d4c:	b94037a1 	ldr	w1, [x29, #52]
     d50:	b9402ba0 	ldr	w0, [x29, #40]
     d54:	1b007c21 	mul	w1, w1, w0
     d58:	b94033a0 	ldr	w0, [x29, #48]
     d5c:	0b000020 	add	w0, w1, w0
     d60:	b90037a0 	str	w0, [x29, #52]
     d64:	f9401fa0 	ldr	x0, [x29, #56]
     d68:	91000401 	add	x1, x0, #0x1
     d6c:	f9001fa1 	str	x1, [x29, #56]
     d70:	39400000 	ldrb	w0, [x0]
     d74:	3900bfa0 	strb	w0, [x29, #47]
     d78:	3940bfa0 	ldrb	w0, [x29, #47]
     d7c:	97ffffc5 	bl	c90 <a2d>
     d80:	b90033a0 	str	w0, [x29, #48]
     d84:	b94033a0 	ldr	w0, [x29, #48]
     d88:	7100001f 	cmp	w0, #0x0
     d8c:	54fffd8a 	b.ge	d3c <a2i+0x2c>  // b.tcont
     d90:	14000002 	b	d98 <a2i+0x88>
     d94:	d503201f 	nop
     d98:	f94013a0 	ldr	x0, [x29, #32]
     d9c:	f9401fa1 	ldr	x1, [x29, #56]
     da0:	f9000001 	str	x1, [x0]
     da4:	f9400fa0 	ldr	x0, [x29, #24]
     da8:	b94037a1 	ldr	w1, [x29, #52]
     dac:	b9000001 	str	w1, [x0]
     db0:	3940bfa0 	ldrb	w0, [x29, #47]
     db4:	a8c47bfd 	ldp	x29, x30, [sp], #64
     db8:	d65f03c0 	ret

0000000000000dbc <putchw>:
     dbc:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
     dc0:	910003fd 	mov	x29, sp
     dc4:	f90017a0 	str	x0, [x29, #40]
     dc8:	f90013a1 	str	x1, [x29, #32]
     dcc:	b9001fa2 	str	w2, [x29, #28]
     dd0:	39006fa3 	strb	w3, [x29, #27]
     dd4:	f9000ba4 	str	x4, [x29, #16]
     dd8:	39406fa0 	ldrb	w0, [x29, #27]
     ddc:	7100001f 	cmp	w0, #0x0
     de0:	54000060 	b.eq	dec <putchw+0x30>  // b.none
     de4:	52800600 	mov	w0, #0x30                  	// #48
     de8:	14000002 	b	df0 <putchw+0x34>
     dec:	52800400 	mov	w0, #0x20                  	// #32
     df0:	3900dfa0 	strb	w0, [x29, #55]
     df4:	f9400ba0 	ldr	x0, [x29, #16]
     df8:	f9001fa0 	str	x0, [x29, #56]
     dfc:	14000004 	b	e0c <putchw+0x50>
     e00:	b9401fa0 	ldr	w0, [x29, #28]
     e04:	51000400 	sub	w0, w0, #0x1
     e08:	b9001fa0 	str	w0, [x29, #28]
     e0c:	f9401fa0 	ldr	x0, [x29, #56]
     e10:	91000401 	add	x1, x0, #0x1
     e14:	f9001fa1 	str	x1, [x29, #56]
     e18:	39400000 	ldrb	w0, [x0]
     e1c:	7100001f 	cmp	w0, #0x0
     e20:	54000120 	b.eq	e44 <putchw+0x88>  // b.none
     e24:	b9401fa0 	ldr	w0, [x29, #28]
     e28:	7100001f 	cmp	w0, #0x0
     e2c:	54fffeac 	b.gt	e00 <putchw+0x44>
     e30:	14000005 	b	e44 <putchw+0x88>
     e34:	f94013a2 	ldr	x2, [x29, #32]
     e38:	3940dfa1 	ldrb	w1, [x29, #55]
     e3c:	f94017a0 	ldr	x0, [x29, #40]
     e40:	d63f0040 	blr	x2
     e44:	b9401fa0 	ldr	w0, [x29, #28]
     e48:	51000401 	sub	w1, w0, #0x1
     e4c:	b9001fa1 	str	w1, [x29, #28]
     e50:	7100001f 	cmp	w0, #0x0
     e54:	54ffff0c 	b.gt	e34 <putchw+0x78>
     e58:	14000005 	b	e6c <putchw+0xb0>
     e5c:	f94013a2 	ldr	x2, [x29, #32]
     e60:	3940dba1 	ldrb	w1, [x29, #54]
     e64:	f94017a0 	ldr	x0, [x29, #40]
     e68:	d63f0040 	blr	x2
     e6c:	f9400ba0 	ldr	x0, [x29, #16]
     e70:	91000401 	add	x1, x0, #0x1
     e74:	f9000ba1 	str	x1, [x29, #16]
     e78:	39400000 	ldrb	w0, [x0]
     e7c:	3900dba0 	strb	w0, [x29, #54]
     e80:	3940dba0 	ldrb	w0, [x29, #54]
     e84:	7100001f 	cmp	w0, #0x0
     e88:	54fffea1 	b.ne	e5c <putchw+0xa0>  // b.any
     e8c:	d503201f 	nop
     e90:	a8c47bfd 	ldp	x29, x30, [sp], #64
     e94:	d65f03c0 	ret

0000000000000e98 <tfp_format>:
     e98:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
     e9c:	910003fd 	mov	x29, sp
     ea0:	f9000bf3 	str	x19, [sp, #16]
     ea4:	f9001fa0 	str	x0, [x29, #56]
     ea8:	f9001ba1 	str	x1, [x29, #48]
     eac:	f90017a2 	str	x2, [x29, #40]
     eb0:	aa0303f3 	mov	x19, x3
     eb4:	140000fd 	b	12a8 <tfp_format+0x410>
     eb8:	39417fa0 	ldrb	w0, [x29, #95]
     ebc:	7100941f 	cmp	w0, #0x25
     ec0:	540000c0 	b.eq	ed8 <tfp_format+0x40>  // b.none
     ec4:	f9401ba2 	ldr	x2, [x29, #48]
     ec8:	39417fa1 	ldrb	w1, [x29, #95]
     ecc:	f9401fa0 	ldr	x0, [x29, #56]
     ed0:	d63f0040 	blr	x2
     ed4:	140000f5 	b	12a8 <tfp_format+0x410>
     ed8:	39017bbf 	strb	wzr, [x29, #94]
     edc:	b9004fbf 	str	wzr, [x29, #76]
     ee0:	f94017a0 	ldr	x0, [x29, #40]
     ee4:	91000401 	add	x1, x0, #0x1
     ee8:	f90017a1 	str	x1, [x29, #40]
     eec:	39400000 	ldrb	w0, [x0]
     ef0:	39017fa0 	strb	w0, [x29, #95]
     ef4:	39417fa0 	ldrb	w0, [x29, #95]
     ef8:	7100c01f 	cmp	w0, #0x30
     efc:	54000101 	b.ne	f1c <tfp_format+0x84>  // b.any
     f00:	f94017a0 	ldr	x0, [x29, #40]
     f04:	91000401 	add	x1, x0, #0x1
     f08:	f90017a1 	str	x1, [x29, #40]
     f0c:	39400000 	ldrb	w0, [x0]
     f10:	39017fa0 	strb	w0, [x29, #95]
     f14:	52800020 	mov	w0, #0x1                   	// #1
     f18:	39017ba0 	strb	w0, [x29, #94]
     f1c:	39417fa0 	ldrb	w0, [x29, #95]
     f20:	7100bc1f 	cmp	w0, #0x2f
     f24:	54000189 	b.ls	f54 <tfp_format+0xbc>  // b.plast
     f28:	39417fa0 	ldrb	w0, [x29, #95]
     f2c:	7100e41f 	cmp	w0, #0x39
     f30:	54000128 	b.hi	f54 <tfp_format+0xbc>  // b.pmore
     f34:	910133a1 	add	x1, x29, #0x4c
     f38:	9100a3a0 	add	x0, x29, #0x28
     f3c:	aa0103e3 	mov	x3, x1
     f40:	52800142 	mov	w2, #0xa                   	// #10
     f44:	aa0003e1 	mov	x1, x0
     f48:	39417fa0 	ldrb	w0, [x29, #95]
     f4c:	97ffff71 	bl	d10 <a2i>
     f50:	39017fa0 	strb	w0, [x29, #95]
     f54:	39417fa0 	ldrb	w0, [x29, #95]
     f58:	71018c1f 	cmp	w0, #0x63
     f5c:	540011c0 	b.eq	1194 <tfp_format+0x2fc>  // b.none
     f60:	71018c1f 	cmp	w0, #0x63
     f64:	5400010c 	b.gt	f84 <tfp_format+0xec>
     f68:	7100941f 	cmp	w0, #0x25
     f6c:	54001940 	b.eq	1294 <tfp_format+0x3fc>  // b.none
     f70:	7101601f 	cmp	w0, #0x58
     f74:	54000b60 	b.eq	10e0 <tfp_format+0x248>  // b.none
     f78:	7100001f 	cmp	w0, #0x0
     f7c:	54001a80 	b.eq	12cc <tfp_format+0x434>  // b.none
     f80:	140000c9 	b	12a4 <tfp_format+0x40c>
     f84:	7101cc1f 	cmp	w0, #0x73
     f88:	54001440 	b.eq	1210 <tfp_format+0x378>  // b.none
     f8c:	7101cc1f 	cmp	w0, #0x73
     f90:	5400008c 	b.gt	fa0 <tfp_format+0x108>
     f94:	7101901f 	cmp	w0, #0x64
     f98:	540005c0 	b.eq	1050 <tfp_format+0x1b8>  // b.none
     f9c:	140000c2 	b	12a4 <tfp_format+0x40c>
     fa0:	7101d41f 	cmp	w0, #0x75
     fa4:	54000080 	b.eq	fb4 <tfp_format+0x11c>  // b.none
     fa8:	7101e01f 	cmp	w0, #0x78
     fac:	540009a0 	b.eq	10e0 <tfp_format+0x248>  // b.none
     fb0:	140000bd 	b	12a4 <tfp_format+0x40c>
     fb4:	b9401a60 	ldr	w0, [x19, #24]
     fb8:	f9400261 	ldr	x1, [x19]
     fbc:	7100001f 	cmp	w0, #0x0
     fc0:	540000eb 	b.lt	fdc <tfp_format+0x144>  // b.tstop
     fc4:	aa0103e0 	mov	x0, x1
     fc8:	91002c00 	add	x0, x0, #0xb
     fcc:	927df000 	and	x0, x0, #0xfffffffffffffff8
     fd0:	f9000260 	str	x0, [x19]
     fd4:	aa0103e0 	mov	x0, x1
     fd8:	1400000f 	b	1014 <tfp_format+0x17c>
     fdc:	11002002 	add	w2, w0, #0x8
     fe0:	b9001a62 	str	w2, [x19, #24]
     fe4:	b9401a62 	ldr	w2, [x19, #24]
     fe8:	7100005f 	cmp	w2, #0x0
     fec:	540000ed 	b.le	1008 <tfp_format+0x170>
     ff0:	aa0103e0 	mov	x0, x1
     ff4:	91002c00 	add	x0, x0, #0xb
     ff8:	927df000 	and	x0, x0, #0xfffffffffffffff8
     ffc:	f9000260 	str	x0, [x19]
    1000:	aa0103e0 	mov	x0, x1
    1004:	14000004 	b	1014 <tfp_format+0x17c>
    1008:	f9400661 	ldr	x1, [x19, #8]
    100c:	93407c00 	sxtw	x0, w0
    1010:	8b000020 	add	x0, x1, x0
    1014:	b9400000 	ldr	w0, [x0]
    1018:	910143a1 	add	x1, x29, #0x50
    101c:	aa0103e3 	mov	x3, x1
    1020:	52800002 	mov	w2, #0x0                   	// #0
    1024:	52800141 	mov	w1, #0xa                   	// #10
    1028:	97fffeb9 	bl	b0c <ui2a>
    102c:	b9404fa0 	ldr	w0, [x29, #76]
    1030:	910143a1 	add	x1, x29, #0x50
    1034:	aa0103e4 	mov	x4, x1
    1038:	39417ba3 	ldrb	w3, [x29, #94]
    103c:	2a0003e2 	mov	w2, w0
    1040:	f9401ba1 	ldr	x1, [x29, #48]
    1044:	f9401fa0 	ldr	x0, [x29, #56]
    1048:	97ffff5d 	bl	dbc <putchw>
    104c:	14000097 	b	12a8 <tfp_format+0x410>
    1050:	b9401a60 	ldr	w0, [x19, #24]
    1054:	f9400261 	ldr	x1, [x19]
    1058:	7100001f 	cmp	w0, #0x0
    105c:	540000eb 	b.lt	1078 <tfp_format+0x1e0>  // b.tstop
    1060:	aa0103e0 	mov	x0, x1
    1064:	91002c00 	add	x0, x0, #0xb
    1068:	927df000 	and	x0, x0, #0xfffffffffffffff8
    106c:	f9000260 	str	x0, [x19]
    1070:	aa0103e0 	mov	x0, x1
    1074:	1400000f 	b	10b0 <tfp_format+0x218>
    1078:	11002002 	add	w2, w0, #0x8
    107c:	b9001a62 	str	w2, [x19, #24]
    1080:	b9401a62 	ldr	w2, [x19, #24]
    1084:	7100005f 	cmp	w2, #0x0
    1088:	540000ed 	b.le	10a4 <tfp_format+0x20c>
    108c:	aa0103e0 	mov	x0, x1
    1090:	91002c00 	add	x0, x0, #0xb
    1094:	927df000 	and	x0, x0, #0xfffffffffffffff8
    1098:	f9000260 	str	x0, [x19]
    109c:	aa0103e0 	mov	x0, x1
    10a0:	14000004 	b	10b0 <tfp_format+0x218>
    10a4:	f9400661 	ldr	x1, [x19, #8]
    10a8:	93407c00 	sxtw	x0, w0
    10ac:	8b000020 	add	x0, x1, x0
    10b0:	b9400000 	ldr	w0, [x0]
    10b4:	910143a1 	add	x1, x29, #0x50
    10b8:	97fffedf 	bl	c34 <i2a>
    10bc:	b9404fa0 	ldr	w0, [x29, #76]
    10c0:	910143a1 	add	x1, x29, #0x50
    10c4:	aa0103e4 	mov	x4, x1
    10c8:	39417ba3 	ldrb	w3, [x29, #94]
    10cc:	2a0003e2 	mov	w2, w0
    10d0:	f9401ba1 	ldr	x1, [x29, #48]
    10d4:	f9401fa0 	ldr	x0, [x29, #56]
    10d8:	97ffff39 	bl	dbc <putchw>
    10dc:	14000073 	b	12a8 <tfp_format+0x410>
    10e0:	b9401a60 	ldr	w0, [x19, #24]
    10e4:	f9400261 	ldr	x1, [x19]
    10e8:	7100001f 	cmp	w0, #0x0
    10ec:	540000eb 	b.lt	1108 <tfp_format+0x270>  // b.tstop
    10f0:	aa0103e0 	mov	x0, x1
    10f4:	91002c00 	add	x0, x0, #0xb
    10f8:	927df000 	and	x0, x0, #0xfffffffffffffff8
    10fc:	f9000260 	str	x0, [x19]
    1100:	aa0103e0 	mov	x0, x1
    1104:	1400000f 	b	1140 <tfp_format+0x2a8>
    1108:	11002002 	add	w2, w0, #0x8
    110c:	b9001a62 	str	w2, [x19, #24]
    1110:	b9401a62 	ldr	w2, [x19, #24]
    1114:	7100005f 	cmp	w2, #0x0
    1118:	540000ed 	b.le	1134 <tfp_format+0x29c>
    111c:	aa0103e0 	mov	x0, x1
    1120:	91002c00 	add	x0, x0, #0xb
    1124:	927df000 	and	x0, x0, #0xfffffffffffffff8
    1128:	f9000260 	str	x0, [x19]
    112c:	aa0103e0 	mov	x0, x1
    1130:	14000004 	b	1140 <tfp_format+0x2a8>
    1134:	f9400661 	ldr	x1, [x19, #8]
    1138:	93407c00 	sxtw	x0, w0
    113c:	8b000020 	add	x0, x1, x0
    1140:	b9400004 	ldr	w4, [x0]
    1144:	39417fa0 	ldrb	w0, [x29, #95]
    1148:	7101601f 	cmp	w0, #0x58
    114c:	1a9f17e0 	cset	w0, eq  // eq = none
    1150:	53001c00 	uxtb	w0, w0
    1154:	2a0003e1 	mov	w1, w0
    1158:	910143a0 	add	x0, x29, #0x50
    115c:	aa0003e3 	mov	x3, x0
    1160:	2a0103e2 	mov	w2, w1
    1164:	52800201 	mov	w1, #0x10                  	// #16
    1168:	2a0403e0 	mov	w0, w4
    116c:	97fffe68 	bl	b0c <ui2a>
    1170:	b9404fa0 	ldr	w0, [x29, #76]
    1174:	910143a1 	add	x1, x29, #0x50
    1178:	aa0103e4 	mov	x4, x1
    117c:	39417ba3 	ldrb	w3, [x29, #94]
    1180:	2a0003e2 	mov	w2, w0
    1184:	f9401ba1 	ldr	x1, [x29, #48]
    1188:	f9401fa0 	ldr	x0, [x29, #56]
    118c:	97ffff0c 	bl	dbc <putchw>
    1190:	14000046 	b	12a8 <tfp_format+0x410>
    1194:	b9401a60 	ldr	w0, [x19, #24]
    1198:	f9400261 	ldr	x1, [x19]
    119c:	7100001f 	cmp	w0, #0x0
    11a0:	540000eb 	b.lt	11bc <tfp_format+0x324>  // b.tstop
    11a4:	aa0103e0 	mov	x0, x1
    11a8:	91002c00 	add	x0, x0, #0xb
    11ac:	927df000 	and	x0, x0, #0xfffffffffffffff8
    11b0:	f9000260 	str	x0, [x19]
    11b4:	aa0103e0 	mov	x0, x1
    11b8:	1400000f 	b	11f4 <tfp_format+0x35c>
    11bc:	11002002 	add	w2, w0, #0x8
    11c0:	b9001a62 	str	w2, [x19, #24]
    11c4:	b9401a62 	ldr	w2, [x19, #24]
    11c8:	7100005f 	cmp	w2, #0x0
    11cc:	540000ed 	b.le	11e8 <tfp_format+0x350>
    11d0:	aa0103e0 	mov	x0, x1
    11d4:	91002c00 	add	x0, x0, #0xb
    11d8:	927df000 	and	x0, x0, #0xfffffffffffffff8
    11dc:	f9000260 	str	x0, [x19]
    11e0:	aa0103e0 	mov	x0, x1
    11e4:	14000004 	b	11f4 <tfp_format+0x35c>
    11e8:	f9400661 	ldr	x1, [x19, #8]
    11ec:	93407c00 	sxtw	x0, w0
    11f0:	8b000020 	add	x0, x1, x0
    11f4:	b9400000 	ldr	w0, [x0]
    11f8:	53001c00 	uxtb	w0, w0
    11fc:	f9401ba2 	ldr	x2, [x29, #48]
    1200:	2a0003e1 	mov	w1, w0
    1204:	f9401fa0 	ldr	x0, [x29, #56]
    1208:	d63f0040 	blr	x2
    120c:	14000027 	b	12a8 <tfp_format+0x410>
    1210:	b9404fa5 	ldr	w5, [x29, #76]
    1214:	b9401a60 	ldr	w0, [x19, #24]
    1218:	f9400261 	ldr	x1, [x19]
    121c:	7100001f 	cmp	w0, #0x0
    1220:	540000eb 	b.lt	123c <tfp_format+0x3a4>  // b.tstop
    1224:	aa0103e0 	mov	x0, x1
    1228:	91003c00 	add	x0, x0, #0xf
    122c:	927df000 	and	x0, x0, #0xfffffffffffffff8
    1230:	f9000260 	str	x0, [x19]
    1234:	aa0103e0 	mov	x0, x1
    1238:	1400000f 	b	1274 <tfp_format+0x3dc>
    123c:	11002002 	add	w2, w0, #0x8
    1240:	b9001a62 	str	w2, [x19, #24]
    1244:	b9401a62 	ldr	w2, [x19, #24]
    1248:	7100005f 	cmp	w2, #0x0
    124c:	540000ed 	b.le	1268 <tfp_format+0x3d0>
    1250:	aa0103e0 	mov	x0, x1
    1254:	91003c00 	add	x0, x0, #0xf
    1258:	927df000 	and	x0, x0, #0xfffffffffffffff8
    125c:	f9000260 	str	x0, [x19]
    1260:	aa0103e0 	mov	x0, x1
    1264:	14000004 	b	1274 <tfp_format+0x3dc>
    1268:	f9400661 	ldr	x1, [x19, #8]
    126c:	93407c00 	sxtw	x0, w0
    1270:	8b000020 	add	x0, x1, x0
    1274:	f9400000 	ldr	x0, [x0]
    1278:	aa0003e4 	mov	x4, x0
    127c:	52800003 	mov	w3, #0x0                   	// #0
    1280:	2a0503e2 	mov	w2, w5
    1284:	f9401ba1 	ldr	x1, [x29, #48]
    1288:	f9401fa0 	ldr	x0, [x29, #56]
    128c:	97fffecc 	bl	dbc <putchw>
    1290:	14000006 	b	12a8 <tfp_format+0x410>
    1294:	f9401ba2 	ldr	x2, [x29, #48]
    1298:	39417fa1 	ldrb	w1, [x29, #95]
    129c:	f9401fa0 	ldr	x0, [x29, #56]
    12a0:	d63f0040 	blr	x2
    12a4:	d503201f 	nop
    12a8:	f94017a0 	ldr	x0, [x29, #40]
    12ac:	91000401 	add	x1, x0, #0x1
    12b0:	f90017a1 	str	x1, [x29, #40]
    12b4:	39400000 	ldrb	w0, [x0]
    12b8:	39017fa0 	strb	w0, [x29, #95]
    12bc:	39417fa0 	ldrb	w0, [x29, #95]
    12c0:	7100001f 	cmp	w0, #0x0
    12c4:	54ffdfa1 	b.ne	eb8 <tfp_format+0x20>  // b.any
    12c8:	14000002 	b	12d0 <tfp_format+0x438>
    12cc:	d503201f 	nop
    12d0:	d503201f 	nop
    12d4:	f9400bf3 	ldr	x19, [sp, #16]
    12d8:	a8c67bfd 	ldp	x29, x30, [sp], #96
    12dc:	d65f03c0 	ret

00000000000012e0 <init_printf>:
    12e0:	d10043ff 	sub	sp, sp, #0x10
    12e4:	f90007e0 	str	x0, [sp, #8]
    12e8:	f90003e1 	str	x1, [sp]
    12ec:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    12f0:	911ee000 	add	x0, x0, #0x7b8
    12f4:	f94003e1 	ldr	x1, [sp]
    12f8:	f9000001 	str	x1, [x0]
    12fc:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1300:	911f0000 	add	x0, x0, #0x7c0
    1304:	f94007e1 	ldr	x1, [sp, #8]
    1308:	f9000001 	str	x1, [x0]
    130c:	d503201f 	nop
    1310:	910043ff 	add	sp, sp, #0x10
    1314:	d65f03c0 	ret

0000000000001318 <tfp_printf>:
    1318:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
    131c:	910003fd 	mov	x29, sp
    1320:	f9001fa0 	str	x0, [x29, #56]
    1324:	f90037a1 	str	x1, [x29, #104]
    1328:	f9003ba2 	str	x2, [x29, #112]
    132c:	f9003fa3 	str	x3, [x29, #120]
    1330:	f90043a4 	str	x4, [x29, #128]
    1334:	f90047a5 	str	x5, [x29, #136]
    1338:	f9004ba6 	str	x6, [x29, #144]
    133c:	f9004fa7 	str	x7, [x29, #152]
    1340:	910283a0 	add	x0, x29, #0xa0
    1344:	f90023a0 	str	x0, [x29, #64]
    1348:	910283a0 	add	x0, x29, #0xa0
    134c:	f90027a0 	str	x0, [x29, #72]
    1350:	910183a0 	add	x0, x29, #0x60
    1354:	f9002ba0 	str	x0, [x29, #80]
    1358:	128006e0 	mov	w0, #0xffffffc8            	// #-56
    135c:	b9005ba0 	str	w0, [x29, #88]
    1360:	b9005fbf 	str	wzr, [x29, #92]
    1364:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1368:	911f0000 	add	x0, x0, #0x7c0
    136c:	f9400004 	ldr	x4, [x0]
    1370:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1374:	911ee000 	add	x0, x0, #0x7b8
    1378:	f9400005 	ldr	x5, [x0]
    137c:	910043a2 	add	x2, x29, #0x10
    1380:	910103a3 	add	x3, x29, #0x40
    1384:	a9400460 	ldp	x0, x1, [x3]
    1388:	a9000440 	stp	x0, x1, [x2]
    138c:	a9410460 	ldp	x0, x1, [x3, #16]
    1390:	a9010440 	stp	x0, x1, [x2, #16]
    1394:	910043a0 	add	x0, x29, #0x10
    1398:	aa0003e3 	mov	x3, x0
    139c:	f9401fa2 	ldr	x2, [x29, #56]
    13a0:	aa0503e1 	mov	x1, x5
    13a4:	aa0403e0 	mov	x0, x4
    13a8:	97fffebc 	bl	e98 <tfp_format>
    13ac:	d503201f 	nop
    13b0:	a8ca7bfd 	ldp	x29, x30, [sp], #160
    13b4:	d65f03c0 	ret

00000000000013b8 <putcp>:
    13b8:	d10043ff 	sub	sp, sp, #0x10
    13bc:	f90007e0 	str	x0, [sp, #8]
    13c0:	39001fe1 	strb	w1, [sp, #7]
    13c4:	f94007e0 	ldr	x0, [sp, #8]
    13c8:	f9400000 	ldr	x0, [x0]
    13cc:	91000402 	add	x2, x0, #0x1
    13d0:	f94007e1 	ldr	x1, [sp, #8]
    13d4:	f9000022 	str	x2, [x1]
    13d8:	39401fe1 	ldrb	w1, [sp, #7]
    13dc:	39000001 	strb	w1, [x0]
    13e0:	d503201f 	nop
    13e4:	910043ff 	add	sp, sp, #0x10
    13e8:	d65f03c0 	ret

00000000000013ec <tfp_sprintf>:
    13ec:	a9b77bfd 	stp	x29, x30, [sp, #-144]!
    13f0:	910003fd 	mov	x29, sp
    13f4:	f9001fa0 	str	x0, [x29, #56]
    13f8:	f9001ba1 	str	x1, [x29, #48]
    13fc:	f90033a2 	str	x2, [x29, #96]
    1400:	f90037a3 	str	x3, [x29, #104]
    1404:	f9003ba4 	str	x4, [x29, #112]
    1408:	f9003fa5 	str	x5, [x29, #120]
    140c:	f90043a6 	str	x6, [x29, #128]
    1410:	f90047a7 	str	x7, [x29, #136]
    1414:	910243a0 	add	x0, x29, #0x90
    1418:	f90023a0 	str	x0, [x29, #64]
    141c:	910243a0 	add	x0, x29, #0x90
    1420:	f90027a0 	str	x0, [x29, #72]
    1424:	910183a0 	add	x0, x29, #0x60
    1428:	f9002ba0 	str	x0, [x29, #80]
    142c:	128005e0 	mov	w0, #0xffffffd0            	// #-48
    1430:	b9005ba0 	str	w0, [x29, #88]
    1434:	b9005fbf 	str	wzr, [x29, #92]
    1438:	910043a2 	add	x2, x29, #0x10
    143c:	910103a3 	add	x3, x29, #0x40
    1440:	a9400460 	ldp	x0, x1, [x3]
    1444:	a9000440 	stp	x0, x1, [x2]
    1448:	a9410460 	ldp	x0, x1, [x3, #16]
    144c:	a9010440 	stp	x0, x1, [x2, #16]
    1450:	910043a2 	add	x2, x29, #0x10
    1454:	90000000 	adrp	x0, 1000 <tfp_format+0x168>
    1458:	910ee001 	add	x1, x0, #0x3b8
    145c:	9100e3a0 	add	x0, x29, #0x38
    1460:	aa0203e3 	mov	x3, x2
    1464:	f9401ba2 	ldr	x2, [x29, #48]
    1468:	97fffe8c 	bl	e98 <tfp_format>
    146c:	9100e3a0 	add	x0, x29, #0x38
    1470:	52800001 	mov	w1, #0x0                   	// #0
    1474:	97ffffd1 	bl	13b8 <putcp>
    1478:	d503201f 	nop
    147c:	a8c97bfd 	ldp	x29, x30, [sp], #144
    1480:	d65f03c0 	ret

0000000000001484 <timer_init>:
    1484:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    1488:	910003fd 	mov	x29, sp
    148c:	d2860080 	mov	x0, #0x3004                	// #12292
    1490:	f2a7e000 	movk	x0, #0x3f00, lsl #16
    1494:	94000039 	bl	1578 <get32>
    1498:	2a0003e1 	mov	w1, w0
    149c:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    14a0:	911f2000 	add	x0, x0, #0x7c8
    14a4:	b9000001 	str	w1, [x0]
    14a8:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    14ac:	911f2000 	add	x0, x0, #0x7c8
    14b0:	b9400001 	ldr	w1, [x0]
    14b4:	5281a800 	mov	w0, #0xd40                 	// #3392
    14b8:	72a00060 	movk	w0, #0x3, lsl #16
    14bc:	0b000021 	add	w1, w1, w0
    14c0:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    14c4:	911f2000 	add	x0, x0, #0x7c8
    14c8:	b9000001 	str	w1, [x0]
    14cc:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    14d0:	911f2000 	add	x0, x0, #0x7c8
    14d4:	b9400000 	ldr	w0, [x0]
    14d8:	2a0003e1 	mov	w1, w0
    14dc:	d2860200 	mov	x0, #0x3010                	// #12304
    14e0:	f2a7e000 	movk	x0, #0x3f00, lsl #16
    14e4:	94000023 	bl	1570 <put32>
    14e8:	d503201f 	nop
    14ec:	a8c17bfd 	ldp	x29, x30, [sp], #16
    14f0:	d65f03c0 	ret

00000000000014f4 <handle_timer_irq>:
    14f4:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
    14f8:	910003fd 	mov	x29, sp
    14fc:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1500:	911f2000 	add	x0, x0, #0x7c8
    1504:	b9400001 	ldr	w1, [x0]
    1508:	5281a800 	mov	w0, #0xd40                 	// #3392
    150c:	72a00060 	movk	w0, #0x3, lsl #16
    1510:	0b000021 	add	w1, w1, w0
    1514:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1518:	911f2000 	add	x0, x0, #0x7c8
    151c:	b9000001 	str	w1, [x0]
    1520:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1524:	911f2000 	add	x0, x0, #0x7c8
    1528:	b9400000 	ldr	w0, [x0]
    152c:	2a0003e1 	mov	w1, w0
    1530:	d2860200 	mov	x0, #0x3010                	// #12304
    1534:	f2a7e000 	movk	x0, #0x3f00, lsl #16
    1538:	9400000e 	bl	1570 <put32>
    153c:	52800041 	mov	w1, #0x2                   	// #2
    1540:	d2860000 	mov	x0, #0x3000                	// #12288
    1544:	f2a7e000 	movk	x0, #0x3f00, lsl #16
    1548:	9400000a 	bl	1570 <put32>
    154c:	b0000000 	adrp	x0, 2000 <irq_invalid_el1t+0x24>
    1550:	911c6000 	add	x0, x0, #0x718
    1554:	97ffff71 	bl	1318 <tfp_printf>
    1558:	d503201f 	nop
    155c:	a8c17bfd 	ldp	x29, x30, [sp], #16
    1560:	d65f03c0 	ret

0000000000001564 <get_el>:
    1564:	d5384240 	mrs	x0, currentel
    1568:	d342fc00 	lsr	x0, x0, #2
    156c:	d65f03c0 	ret

0000000000001570 <put32>:
    1570:	b9000001 	str	w1, [x0]
    1574:	d65f03c0 	ret

0000000000001578 <get32>:
    1578:	b9400000 	ldr	w0, [x0]
    157c:	d65f03c0 	ret

0000000000001580 <delay>:
    1580:	f1000400 	subs	x0, x0, #0x1
    1584:	54ffffe1 	b.ne	1580 <delay>  // b.any
    1588:	d65f03c0 	ret

000000000000158c <irq_vector_init>:
    158c:	100013a0 	adr	x0, 1800 <vectors>
    1590:	d518c000 	msr	vbar_el1, x0
    1594:	d65f03c0 	ret

0000000000001598 <enable_irq>:
    1598:	d50342ff 	msr	daifclr, #0x2
    159c:	d65f03c0 	ret

00000000000015a0 <disable_irq>:
    15a0:	d50342df 	msr	daifset, #0x2
    15a4:	d65f03c0 	ret
	...

0000000000001800 <vectors>:
    1800:	140001e1 	b	1f84 <sync_invalid_el1t>
    1804:	d503201f 	nop
    1808:	d503201f 	nop
    180c:	d503201f 	nop
    1810:	d503201f 	nop
    1814:	d503201f 	nop
    1818:	d503201f 	nop
    181c:	d503201f 	nop
    1820:	d503201f 	nop
    1824:	d503201f 	nop
    1828:	d503201f 	nop
    182c:	d503201f 	nop
    1830:	d503201f 	nop
    1834:	d503201f 	nop
    1838:	d503201f 	nop
    183c:	d503201f 	nop
    1840:	d503201f 	nop
    1844:	d503201f 	nop
    1848:	d503201f 	nop
    184c:	d503201f 	nop
    1850:	d503201f 	nop
    1854:	d503201f 	nop
    1858:	d503201f 	nop
    185c:	d503201f 	nop
    1860:	d503201f 	nop
    1864:	d503201f 	nop
    1868:	d503201f 	nop
    186c:	d503201f 	nop
    1870:	d503201f 	nop
    1874:	d503201f 	nop
    1878:	d503201f 	nop
    187c:	d503201f 	nop
    1880:	140001d7 	b	1fdc <irq_invalid_el1t>
    1884:	d503201f 	nop
    1888:	d503201f 	nop
    188c:	d503201f 	nop
    1890:	d503201f 	nop
    1894:	d503201f 	nop
    1898:	d503201f 	nop
    189c:	d503201f 	nop
    18a0:	d503201f 	nop
    18a4:	d503201f 	nop
    18a8:	d503201f 	nop
    18ac:	d503201f 	nop
    18b0:	d503201f 	nop
    18b4:	d503201f 	nop
    18b8:	d503201f 	nop
    18bc:	d503201f 	nop
    18c0:	d503201f 	nop
    18c4:	d503201f 	nop
    18c8:	d503201f 	nop
    18cc:	d503201f 	nop
    18d0:	d503201f 	nop
    18d4:	d503201f 	nop
    18d8:	d503201f 	nop
    18dc:	d503201f 	nop
    18e0:	d503201f 	nop
    18e4:	d503201f 	nop
    18e8:	d503201f 	nop
    18ec:	d503201f 	nop
    18f0:	d503201f 	nop
    18f4:	d503201f 	nop
    18f8:	d503201f 	nop
    18fc:	d503201f 	nop
    1900:	140001cd 	b	2034 <fiq_invalid_el1t>
    1904:	d503201f 	nop
    1908:	d503201f 	nop
    190c:	d503201f 	nop
    1910:	d503201f 	nop
    1914:	d503201f 	nop
    1918:	d503201f 	nop
    191c:	d503201f 	nop
    1920:	d503201f 	nop
    1924:	d503201f 	nop
    1928:	d503201f 	nop
    192c:	d503201f 	nop
    1930:	d503201f 	nop
    1934:	d503201f 	nop
    1938:	d503201f 	nop
    193c:	d503201f 	nop
    1940:	d503201f 	nop
    1944:	d503201f 	nop
    1948:	d503201f 	nop
    194c:	d503201f 	nop
    1950:	d503201f 	nop
    1954:	d503201f 	nop
    1958:	d503201f 	nop
    195c:	d503201f 	nop
    1960:	d503201f 	nop
    1964:	d503201f 	nop
    1968:	d503201f 	nop
    196c:	d503201f 	nop
    1970:	d503201f 	nop
    1974:	d503201f 	nop
    1978:	d503201f 	nop
    197c:	d503201f 	nop
    1980:	140001c3 	b	208c <error_invalid_el1t>
    1984:	d503201f 	nop
    1988:	d503201f 	nop
    198c:	d503201f 	nop
    1990:	d503201f 	nop
    1994:	d503201f 	nop
    1998:	d503201f 	nop
    199c:	d503201f 	nop
    19a0:	d503201f 	nop
    19a4:	d503201f 	nop
    19a8:	d503201f 	nop
    19ac:	d503201f 	nop
    19b0:	d503201f 	nop
    19b4:	d503201f 	nop
    19b8:	d503201f 	nop
    19bc:	d503201f 	nop
    19c0:	d503201f 	nop
    19c4:	d503201f 	nop
    19c8:	d503201f 	nop
    19cc:	d503201f 	nop
    19d0:	d503201f 	nop
    19d4:	d503201f 	nop
    19d8:	d503201f 	nop
    19dc:	d503201f 	nop
    19e0:	d503201f 	nop
    19e4:	d503201f 	nop
    19e8:	d503201f 	nop
    19ec:	d503201f 	nop
    19f0:	d503201f 	nop
    19f4:	d503201f 	nop
    19f8:	d503201f 	nop
    19fc:	d503201f 	nop
    1a00:	140001b9 	b	20e4 <sync_invalid_el1h>
    1a04:	d503201f 	nop
    1a08:	d503201f 	nop
    1a0c:	d503201f 	nop
    1a10:	d503201f 	nop
    1a14:	d503201f 	nop
    1a18:	d503201f 	nop
    1a1c:	d503201f 	nop
    1a20:	d503201f 	nop
    1a24:	d503201f 	nop
    1a28:	d503201f 	nop
    1a2c:	d503201f 	nop
    1a30:	d503201f 	nop
    1a34:	d503201f 	nop
    1a38:	d503201f 	nop
    1a3c:	d503201f 	nop
    1a40:	d503201f 	nop
    1a44:	d503201f 	nop
    1a48:	d503201f 	nop
    1a4c:	d503201f 	nop
    1a50:	d503201f 	nop
    1a54:	d503201f 	nop
    1a58:	d503201f 	nop
    1a5c:	d503201f 	nop
    1a60:	d503201f 	nop
    1a64:	d503201f 	nop
    1a68:	d503201f 	nop
    1a6c:	d503201f 	nop
    1a70:	d503201f 	nop
    1a74:	d503201f 	nop
    1a78:	d503201f 	nop
    1a7c:	d503201f 	nop
    1a80:	1400028b 	b	24ac <el1_irq>
    1a84:	d503201f 	nop
    1a88:	d503201f 	nop
    1a8c:	d503201f 	nop
    1a90:	d503201f 	nop
    1a94:	d503201f 	nop
    1a98:	d503201f 	nop
    1a9c:	d503201f 	nop
    1aa0:	d503201f 	nop
    1aa4:	d503201f 	nop
    1aa8:	d503201f 	nop
    1aac:	d503201f 	nop
    1ab0:	d503201f 	nop
    1ab4:	d503201f 	nop
    1ab8:	d503201f 	nop
    1abc:	d503201f 	nop
    1ac0:	d503201f 	nop
    1ac4:	d503201f 	nop
    1ac8:	d503201f 	nop
    1acc:	d503201f 	nop
    1ad0:	d503201f 	nop
    1ad4:	d503201f 	nop
    1ad8:	d503201f 	nop
    1adc:	d503201f 	nop
    1ae0:	d503201f 	nop
    1ae4:	d503201f 	nop
    1ae8:	d503201f 	nop
    1aec:	d503201f 	nop
    1af0:	d503201f 	nop
    1af4:	d503201f 	nop
    1af8:	d503201f 	nop
    1afc:	d503201f 	nop
    1b00:	1400018f 	b	213c <fiq_invalid_el1h>
    1b04:	d503201f 	nop
    1b08:	d503201f 	nop
    1b0c:	d503201f 	nop
    1b10:	d503201f 	nop
    1b14:	d503201f 	nop
    1b18:	d503201f 	nop
    1b1c:	d503201f 	nop
    1b20:	d503201f 	nop
    1b24:	d503201f 	nop
    1b28:	d503201f 	nop
    1b2c:	d503201f 	nop
    1b30:	d503201f 	nop
    1b34:	d503201f 	nop
    1b38:	d503201f 	nop
    1b3c:	d503201f 	nop
    1b40:	d503201f 	nop
    1b44:	d503201f 	nop
    1b48:	d503201f 	nop
    1b4c:	d503201f 	nop
    1b50:	d503201f 	nop
    1b54:	d503201f 	nop
    1b58:	d503201f 	nop
    1b5c:	d503201f 	nop
    1b60:	d503201f 	nop
    1b64:	d503201f 	nop
    1b68:	d503201f 	nop
    1b6c:	d503201f 	nop
    1b70:	d503201f 	nop
    1b74:	d503201f 	nop
    1b78:	d503201f 	nop
    1b7c:	d503201f 	nop
    1b80:	14000185 	b	2194 <error_invalid_el1h>
    1b84:	d503201f 	nop
    1b88:	d503201f 	nop
    1b8c:	d503201f 	nop
    1b90:	d503201f 	nop
    1b94:	d503201f 	nop
    1b98:	d503201f 	nop
    1b9c:	d503201f 	nop
    1ba0:	d503201f 	nop
    1ba4:	d503201f 	nop
    1ba8:	d503201f 	nop
    1bac:	d503201f 	nop
    1bb0:	d503201f 	nop
    1bb4:	d503201f 	nop
    1bb8:	d503201f 	nop
    1bbc:	d503201f 	nop
    1bc0:	d503201f 	nop
    1bc4:	d503201f 	nop
    1bc8:	d503201f 	nop
    1bcc:	d503201f 	nop
    1bd0:	d503201f 	nop
    1bd4:	d503201f 	nop
    1bd8:	d503201f 	nop
    1bdc:	d503201f 	nop
    1be0:	d503201f 	nop
    1be4:	d503201f 	nop
    1be8:	d503201f 	nop
    1bec:	d503201f 	nop
    1bf0:	d503201f 	nop
    1bf4:	d503201f 	nop
    1bf8:	d503201f 	nop
    1bfc:	d503201f 	nop
    1c00:	1400017b 	b	21ec <sync_invalid_el0_64>
    1c04:	d503201f 	nop
    1c08:	d503201f 	nop
    1c0c:	d503201f 	nop
    1c10:	d503201f 	nop
    1c14:	d503201f 	nop
    1c18:	d503201f 	nop
    1c1c:	d503201f 	nop
    1c20:	d503201f 	nop
    1c24:	d503201f 	nop
    1c28:	d503201f 	nop
    1c2c:	d503201f 	nop
    1c30:	d503201f 	nop
    1c34:	d503201f 	nop
    1c38:	d503201f 	nop
    1c3c:	d503201f 	nop
    1c40:	d503201f 	nop
    1c44:	d503201f 	nop
    1c48:	d503201f 	nop
    1c4c:	d503201f 	nop
    1c50:	d503201f 	nop
    1c54:	d503201f 	nop
    1c58:	d503201f 	nop
    1c5c:	d503201f 	nop
    1c60:	d503201f 	nop
    1c64:	d503201f 	nop
    1c68:	d503201f 	nop
    1c6c:	d503201f 	nop
    1c70:	d503201f 	nop
    1c74:	d503201f 	nop
    1c78:	d503201f 	nop
    1c7c:	d503201f 	nop
    1c80:	14000171 	b	2244 <irq_invalid_el0_64>
    1c84:	d503201f 	nop
    1c88:	d503201f 	nop
    1c8c:	d503201f 	nop
    1c90:	d503201f 	nop
    1c94:	d503201f 	nop
    1c98:	d503201f 	nop
    1c9c:	d503201f 	nop
    1ca0:	d503201f 	nop
    1ca4:	d503201f 	nop
    1ca8:	d503201f 	nop
    1cac:	d503201f 	nop
    1cb0:	d503201f 	nop
    1cb4:	d503201f 	nop
    1cb8:	d503201f 	nop
    1cbc:	d503201f 	nop
    1cc0:	d503201f 	nop
    1cc4:	d503201f 	nop
    1cc8:	d503201f 	nop
    1ccc:	d503201f 	nop
    1cd0:	d503201f 	nop
    1cd4:	d503201f 	nop
    1cd8:	d503201f 	nop
    1cdc:	d503201f 	nop
    1ce0:	d503201f 	nop
    1ce4:	d503201f 	nop
    1ce8:	d503201f 	nop
    1cec:	d503201f 	nop
    1cf0:	d503201f 	nop
    1cf4:	d503201f 	nop
    1cf8:	d503201f 	nop
    1cfc:	d503201f 	nop
    1d00:	14000167 	b	229c <fiq_invalid_el0_64>
    1d04:	d503201f 	nop
    1d08:	d503201f 	nop
    1d0c:	d503201f 	nop
    1d10:	d503201f 	nop
    1d14:	d503201f 	nop
    1d18:	d503201f 	nop
    1d1c:	d503201f 	nop
    1d20:	d503201f 	nop
    1d24:	d503201f 	nop
    1d28:	d503201f 	nop
    1d2c:	d503201f 	nop
    1d30:	d503201f 	nop
    1d34:	d503201f 	nop
    1d38:	d503201f 	nop
    1d3c:	d503201f 	nop
    1d40:	d503201f 	nop
    1d44:	d503201f 	nop
    1d48:	d503201f 	nop
    1d4c:	d503201f 	nop
    1d50:	d503201f 	nop
    1d54:	d503201f 	nop
    1d58:	d503201f 	nop
    1d5c:	d503201f 	nop
    1d60:	d503201f 	nop
    1d64:	d503201f 	nop
    1d68:	d503201f 	nop
    1d6c:	d503201f 	nop
    1d70:	d503201f 	nop
    1d74:	d503201f 	nop
    1d78:	d503201f 	nop
    1d7c:	d503201f 	nop
    1d80:	1400015d 	b	22f4 <error_invalid_el0_64>
    1d84:	d503201f 	nop
    1d88:	d503201f 	nop
    1d8c:	d503201f 	nop
    1d90:	d503201f 	nop
    1d94:	d503201f 	nop
    1d98:	d503201f 	nop
    1d9c:	d503201f 	nop
    1da0:	d503201f 	nop
    1da4:	d503201f 	nop
    1da8:	d503201f 	nop
    1dac:	d503201f 	nop
    1db0:	d503201f 	nop
    1db4:	d503201f 	nop
    1db8:	d503201f 	nop
    1dbc:	d503201f 	nop
    1dc0:	d503201f 	nop
    1dc4:	d503201f 	nop
    1dc8:	d503201f 	nop
    1dcc:	d503201f 	nop
    1dd0:	d503201f 	nop
    1dd4:	d503201f 	nop
    1dd8:	d503201f 	nop
    1ddc:	d503201f 	nop
    1de0:	d503201f 	nop
    1de4:	d503201f 	nop
    1de8:	d503201f 	nop
    1dec:	d503201f 	nop
    1df0:	d503201f 	nop
    1df4:	d503201f 	nop
    1df8:	d503201f 	nop
    1dfc:	d503201f 	nop
    1e00:	14000153 	b	234c <sync_invalid_el0_32>
    1e04:	d503201f 	nop
    1e08:	d503201f 	nop
    1e0c:	d503201f 	nop
    1e10:	d503201f 	nop
    1e14:	d503201f 	nop
    1e18:	d503201f 	nop
    1e1c:	d503201f 	nop
    1e20:	d503201f 	nop
    1e24:	d503201f 	nop
    1e28:	d503201f 	nop
    1e2c:	d503201f 	nop
    1e30:	d503201f 	nop
    1e34:	d503201f 	nop
    1e38:	d503201f 	nop
    1e3c:	d503201f 	nop
    1e40:	d503201f 	nop
    1e44:	d503201f 	nop
    1e48:	d503201f 	nop
    1e4c:	d503201f 	nop
    1e50:	d503201f 	nop
    1e54:	d503201f 	nop
    1e58:	d503201f 	nop
    1e5c:	d503201f 	nop
    1e60:	d503201f 	nop
    1e64:	d503201f 	nop
    1e68:	d503201f 	nop
    1e6c:	d503201f 	nop
    1e70:	d503201f 	nop
    1e74:	d503201f 	nop
    1e78:	d503201f 	nop
    1e7c:	d503201f 	nop
    1e80:	14000149 	b	23a4 <irq_invalid_el0_32>
    1e84:	d503201f 	nop
    1e88:	d503201f 	nop
    1e8c:	d503201f 	nop
    1e90:	d503201f 	nop
    1e94:	d503201f 	nop
    1e98:	d503201f 	nop
    1e9c:	d503201f 	nop
    1ea0:	d503201f 	nop
    1ea4:	d503201f 	nop
    1ea8:	d503201f 	nop
    1eac:	d503201f 	nop
    1eb0:	d503201f 	nop
    1eb4:	d503201f 	nop
    1eb8:	d503201f 	nop
    1ebc:	d503201f 	nop
    1ec0:	d503201f 	nop
    1ec4:	d503201f 	nop
    1ec8:	d503201f 	nop
    1ecc:	d503201f 	nop
    1ed0:	d503201f 	nop
    1ed4:	d503201f 	nop
    1ed8:	d503201f 	nop
    1edc:	d503201f 	nop
    1ee0:	d503201f 	nop
    1ee4:	d503201f 	nop
    1ee8:	d503201f 	nop
    1eec:	d503201f 	nop
    1ef0:	d503201f 	nop
    1ef4:	d503201f 	nop
    1ef8:	d503201f 	nop
    1efc:	d503201f 	nop
    1f00:	1400013f 	b	23fc <fiq_invalid_el0_32>
    1f04:	d503201f 	nop
    1f08:	d503201f 	nop
    1f0c:	d503201f 	nop
    1f10:	d503201f 	nop
    1f14:	d503201f 	nop
    1f18:	d503201f 	nop
    1f1c:	d503201f 	nop
    1f20:	d503201f 	nop
    1f24:	d503201f 	nop
    1f28:	d503201f 	nop
    1f2c:	d503201f 	nop
    1f30:	d503201f 	nop
    1f34:	d503201f 	nop
    1f38:	d503201f 	nop
    1f3c:	d503201f 	nop
    1f40:	d503201f 	nop
    1f44:	d503201f 	nop
    1f48:	d503201f 	nop
    1f4c:	d503201f 	nop
    1f50:	d503201f 	nop
    1f54:	d503201f 	nop
    1f58:	d503201f 	nop
    1f5c:	d503201f 	nop
    1f60:	d503201f 	nop
    1f64:	d503201f 	nop
    1f68:	d503201f 	nop
    1f6c:	d503201f 	nop
    1f70:	d503201f 	nop
    1f74:	d503201f 	nop
    1f78:	d503201f 	nop
    1f7c:	d503201f 	nop
    1f80:	14000135 	b	2454 <error_invalid_el0_32>

0000000000001f84 <sync_invalid_el1t>:
    1f84:	d10403ff 	sub	sp, sp, #0x100
    1f88:	a90007e0 	stp	x0, x1, [sp]
    1f8c:	a9010fe2 	stp	x2, x3, [sp, #16]
    1f90:	a90217e4 	stp	x4, x5, [sp, #32]
    1f94:	a9031fe6 	stp	x6, x7, [sp, #48]
    1f98:	a90427e8 	stp	x8, x9, [sp, #64]
    1f9c:	a9052fea 	stp	x10, x11, [sp, #80]
    1fa0:	a90637ec 	stp	x12, x13, [sp, #96]
    1fa4:	a9073fee 	stp	x14, x15, [sp, #112]
    1fa8:	a90847f0 	stp	x16, x17, [sp, #128]
    1fac:	a9094ff2 	stp	x18, x19, [sp, #144]
    1fb0:	a90a57f4 	stp	x20, x21, [sp, #160]
    1fb4:	a90b5ff6 	stp	x22, x23, [sp, #176]
    1fb8:	a90c67f8 	stp	x24, x25, [sp, #192]
    1fbc:	a90d6ffa 	stp	x26, x27, [sp, #208]
    1fc0:	a90e77fc 	stp	x28, x29, [sp, #224]
    1fc4:	f9007bfe 	str	x30, [sp, #240]
    1fc8:	d2800000 	mov	x0, #0x0                   	// #0
    1fcc:	d5385201 	mrs	x1, esr_el1
    1fd0:	d5384022 	mrs	x2, elr_el1
    1fd4:	97fffa24 	bl	864 <show_invalid_entry_message>
    1fd8:	14000159 	b	253c <err_hang>

0000000000001fdc <irq_invalid_el1t>:
    1fdc:	d10403ff 	sub	sp, sp, #0x100
    1fe0:	a90007e0 	stp	x0, x1, [sp]
    1fe4:	a9010fe2 	stp	x2, x3, [sp, #16]
    1fe8:	a90217e4 	stp	x4, x5, [sp, #32]
    1fec:	a9031fe6 	stp	x6, x7, [sp, #48]
    1ff0:	a90427e8 	stp	x8, x9, [sp, #64]
    1ff4:	a9052fea 	stp	x10, x11, [sp, #80]
    1ff8:	a90637ec 	stp	x12, x13, [sp, #96]
    1ffc:	a9073fee 	stp	x14, x15, [sp, #112]
    2000:	a90847f0 	stp	x16, x17, [sp, #128]
    2004:	a9094ff2 	stp	x18, x19, [sp, #144]
    2008:	a90a57f4 	stp	x20, x21, [sp, #160]
    200c:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2010:	a90c67f8 	stp	x24, x25, [sp, #192]
    2014:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2018:	a90e77fc 	stp	x28, x29, [sp, #224]
    201c:	f9007bfe 	str	x30, [sp, #240]
    2020:	d2800020 	mov	x0, #0x1                   	// #1
    2024:	d5385201 	mrs	x1, esr_el1
    2028:	d5384022 	mrs	x2, elr_el1
    202c:	97fffa0e 	bl	864 <show_invalid_entry_message>
    2030:	14000143 	b	253c <err_hang>

0000000000002034 <fiq_invalid_el1t>:
    2034:	d10403ff 	sub	sp, sp, #0x100
    2038:	a90007e0 	stp	x0, x1, [sp]
    203c:	a9010fe2 	stp	x2, x3, [sp, #16]
    2040:	a90217e4 	stp	x4, x5, [sp, #32]
    2044:	a9031fe6 	stp	x6, x7, [sp, #48]
    2048:	a90427e8 	stp	x8, x9, [sp, #64]
    204c:	a9052fea 	stp	x10, x11, [sp, #80]
    2050:	a90637ec 	stp	x12, x13, [sp, #96]
    2054:	a9073fee 	stp	x14, x15, [sp, #112]
    2058:	a90847f0 	stp	x16, x17, [sp, #128]
    205c:	a9094ff2 	stp	x18, x19, [sp, #144]
    2060:	a90a57f4 	stp	x20, x21, [sp, #160]
    2064:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2068:	a90c67f8 	stp	x24, x25, [sp, #192]
    206c:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2070:	a90e77fc 	stp	x28, x29, [sp, #224]
    2074:	f9007bfe 	str	x30, [sp, #240]
    2078:	d2800040 	mov	x0, #0x2                   	// #2
    207c:	d5385201 	mrs	x1, esr_el1
    2080:	d5384022 	mrs	x2, elr_el1
    2084:	97fff9f8 	bl	864 <show_invalid_entry_message>
    2088:	1400012d 	b	253c <err_hang>

000000000000208c <error_invalid_el1t>:
    208c:	d10403ff 	sub	sp, sp, #0x100
    2090:	a90007e0 	stp	x0, x1, [sp]
    2094:	a9010fe2 	stp	x2, x3, [sp, #16]
    2098:	a90217e4 	stp	x4, x5, [sp, #32]
    209c:	a9031fe6 	stp	x6, x7, [sp, #48]
    20a0:	a90427e8 	stp	x8, x9, [sp, #64]
    20a4:	a9052fea 	stp	x10, x11, [sp, #80]
    20a8:	a90637ec 	stp	x12, x13, [sp, #96]
    20ac:	a9073fee 	stp	x14, x15, [sp, #112]
    20b0:	a90847f0 	stp	x16, x17, [sp, #128]
    20b4:	a9094ff2 	stp	x18, x19, [sp, #144]
    20b8:	a90a57f4 	stp	x20, x21, [sp, #160]
    20bc:	a90b5ff6 	stp	x22, x23, [sp, #176]
    20c0:	a90c67f8 	stp	x24, x25, [sp, #192]
    20c4:	a90d6ffa 	stp	x26, x27, [sp, #208]
    20c8:	a90e77fc 	stp	x28, x29, [sp, #224]
    20cc:	f9007bfe 	str	x30, [sp, #240]
    20d0:	d2800060 	mov	x0, #0x3                   	// #3
    20d4:	d5385201 	mrs	x1, esr_el1
    20d8:	d5384022 	mrs	x2, elr_el1
    20dc:	97fff9e2 	bl	864 <show_invalid_entry_message>
    20e0:	14000117 	b	253c <err_hang>

00000000000020e4 <sync_invalid_el1h>:
    20e4:	d10403ff 	sub	sp, sp, #0x100
    20e8:	a90007e0 	stp	x0, x1, [sp]
    20ec:	a9010fe2 	stp	x2, x3, [sp, #16]
    20f0:	a90217e4 	stp	x4, x5, [sp, #32]
    20f4:	a9031fe6 	stp	x6, x7, [sp, #48]
    20f8:	a90427e8 	stp	x8, x9, [sp, #64]
    20fc:	a9052fea 	stp	x10, x11, [sp, #80]
    2100:	a90637ec 	stp	x12, x13, [sp, #96]
    2104:	a9073fee 	stp	x14, x15, [sp, #112]
    2108:	a90847f0 	stp	x16, x17, [sp, #128]
    210c:	a9094ff2 	stp	x18, x19, [sp, #144]
    2110:	a90a57f4 	stp	x20, x21, [sp, #160]
    2114:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2118:	a90c67f8 	stp	x24, x25, [sp, #192]
    211c:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2120:	a90e77fc 	stp	x28, x29, [sp, #224]
    2124:	f9007bfe 	str	x30, [sp, #240]
    2128:	d2800080 	mov	x0, #0x4                   	// #4
    212c:	d5385201 	mrs	x1, esr_el1
    2130:	d5384022 	mrs	x2, elr_el1
    2134:	97fff9cc 	bl	864 <show_invalid_entry_message>
    2138:	14000101 	b	253c <err_hang>

000000000000213c <fiq_invalid_el1h>:
    213c:	d10403ff 	sub	sp, sp, #0x100
    2140:	a90007e0 	stp	x0, x1, [sp]
    2144:	a9010fe2 	stp	x2, x3, [sp, #16]
    2148:	a90217e4 	stp	x4, x5, [sp, #32]
    214c:	a9031fe6 	stp	x6, x7, [sp, #48]
    2150:	a90427e8 	stp	x8, x9, [sp, #64]
    2154:	a9052fea 	stp	x10, x11, [sp, #80]
    2158:	a90637ec 	stp	x12, x13, [sp, #96]
    215c:	a9073fee 	stp	x14, x15, [sp, #112]
    2160:	a90847f0 	stp	x16, x17, [sp, #128]
    2164:	a9094ff2 	stp	x18, x19, [sp, #144]
    2168:	a90a57f4 	stp	x20, x21, [sp, #160]
    216c:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2170:	a90c67f8 	stp	x24, x25, [sp, #192]
    2174:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2178:	a90e77fc 	stp	x28, x29, [sp, #224]
    217c:	f9007bfe 	str	x30, [sp, #240]
    2180:	d28000c0 	mov	x0, #0x6                   	// #6
    2184:	d5385201 	mrs	x1, esr_el1
    2188:	d5384022 	mrs	x2, elr_el1
    218c:	97fff9b6 	bl	864 <show_invalid_entry_message>
    2190:	140000eb 	b	253c <err_hang>

0000000000002194 <error_invalid_el1h>:
    2194:	d10403ff 	sub	sp, sp, #0x100
    2198:	a90007e0 	stp	x0, x1, [sp]
    219c:	a9010fe2 	stp	x2, x3, [sp, #16]
    21a0:	a90217e4 	stp	x4, x5, [sp, #32]
    21a4:	a9031fe6 	stp	x6, x7, [sp, #48]
    21a8:	a90427e8 	stp	x8, x9, [sp, #64]
    21ac:	a9052fea 	stp	x10, x11, [sp, #80]
    21b0:	a90637ec 	stp	x12, x13, [sp, #96]
    21b4:	a9073fee 	stp	x14, x15, [sp, #112]
    21b8:	a90847f0 	stp	x16, x17, [sp, #128]
    21bc:	a9094ff2 	stp	x18, x19, [sp, #144]
    21c0:	a90a57f4 	stp	x20, x21, [sp, #160]
    21c4:	a90b5ff6 	stp	x22, x23, [sp, #176]
    21c8:	a90c67f8 	stp	x24, x25, [sp, #192]
    21cc:	a90d6ffa 	stp	x26, x27, [sp, #208]
    21d0:	a90e77fc 	stp	x28, x29, [sp, #224]
    21d4:	f9007bfe 	str	x30, [sp, #240]
    21d8:	d28000e0 	mov	x0, #0x7                   	// #7
    21dc:	d5385201 	mrs	x1, esr_el1
    21e0:	d5384022 	mrs	x2, elr_el1
    21e4:	97fff9a0 	bl	864 <show_invalid_entry_message>
    21e8:	140000d5 	b	253c <err_hang>

00000000000021ec <sync_invalid_el0_64>:
    21ec:	d10403ff 	sub	sp, sp, #0x100
    21f0:	a90007e0 	stp	x0, x1, [sp]
    21f4:	a9010fe2 	stp	x2, x3, [sp, #16]
    21f8:	a90217e4 	stp	x4, x5, [sp, #32]
    21fc:	a9031fe6 	stp	x6, x7, [sp, #48]
    2200:	a90427e8 	stp	x8, x9, [sp, #64]
    2204:	a9052fea 	stp	x10, x11, [sp, #80]
    2208:	a90637ec 	stp	x12, x13, [sp, #96]
    220c:	a9073fee 	stp	x14, x15, [sp, #112]
    2210:	a90847f0 	stp	x16, x17, [sp, #128]
    2214:	a9094ff2 	stp	x18, x19, [sp, #144]
    2218:	a90a57f4 	stp	x20, x21, [sp, #160]
    221c:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2220:	a90c67f8 	stp	x24, x25, [sp, #192]
    2224:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2228:	a90e77fc 	stp	x28, x29, [sp, #224]
    222c:	f9007bfe 	str	x30, [sp, #240]
    2230:	d2800100 	mov	x0, #0x8                   	// #8
    2234:	d5385201 	mrs	x1, esr_el1
    2238:	d5384022 	mrs	x2, elr_el1
    223c:	97fff98a 	bl	864 <show_invalid_entry_message>
    2240:	140000bf 	b	253c <err_hang>

0000000000002244 <irq_invalid_el0_64>:
    2244:	d10403ff 	sub	sp, sp, #0x100
    2248:	a90007e0 	stp	x0, x1, [sp]
    224c:	a9010fe2 	stp	x2, x3, [sp, #16]
    2250:	a90217e4 	stp	x4, x5, [sp, #32]
    2254:	a9031fe6 	stp	x6, x7, [sp, #48]
    2258:	a90427e8 	stp	x8, x9, [sp, #64]
    225c:	a9052fea 	stp	x10, x11, [sp, #80]
    2260:	a90637ec 	stp	x12, x13, [sp, #96]
    2264:	a9073fee 	stp	x14, x15, [sp, #112]
    2268:	a90847f0 	stp	x16, x17, [sp, #128]
    226c:	a9094ff2 	stp	x18, x19, [sp, #144]
    2270:	a90a57f4 	stp	x20, x21, [sp, #160]
    2274:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2278:	a90c67f8 	stp	x24, x25, [sp, #192]
    227c:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2280:	a90e77fc 	stp	x28, x29, [sp, #224]
    2284:	f9007bfe 	str	x30, [sp, #240]
    2288:	d2800120 	mov	x0, #0x9                   	// #9
    228c:	d5385201 	mrs	x1, esr_el1
    2290:	d5384022 	mrs	x2, elr_el1
    2294:	97fff974 	bl	864 <show_invalid_entry_message>
    2298:	140000a9 	b	253c <err_hang>

000000000000229c <fiq_invalid_el0_64>:
    229c:	d10403ff 	sub	sp, sp, #0x100
    22a0:	a90007e0 	stp	x0, x1, [sp]
    22a4:	a9010fe2 	stp	x2, x3, [sp, #16]
    22a8:	a90217e4 	stp	x4, x5, [sp, #32]
    22ac:	a9031fe6 	stp	x6, x7, [sp, #48]
    22b0:	a90427e8 	stp	x8, x9, [sp, #64]
    22b4:	a9052fea 	stp	x10, x11, [sp, #80]
    22b8:	a90637ec 	stp	x12, x13, [sp, #96]
    22bc:	a9073fee 	stp	x14, x15, [sp, #112]
    22c0:	a90847f0 	stp	x16, x17, [sp, #128]
    22c4:	a9094ff2 	stp	x18, x19, [sp, #144]
    22c8:	a90a57f4 	stp	x20, x21, [sp, #160]
    22cc:	a90b5ff6 	stp	x22, x23, [sp, #176]
    22d0:	a90c67f8 	stp	x24, x25, [sp, #192]
    22d4:	a90d6ffa 	stp	x26, x27, [sp, #208]
    22d8:	a90e77fc 	stp	x28, x29, [sp, #224]
    22dc:	f9007bfe 	str	x30, [sp, #240]
    22e0:	d2800140 	mov	x0, #0xa                   	// #10
    22e4:	d5385201 	mrs	x1, esr_el1
    22e8:	d5384022 	mrs	x2, elr_el1
    22ec:	97fff95e 	bl	864 <show_invalid_entry_message>
    22f0:	14000093 	b	253c <err_hang>

00000000000022f4 <error_invalid_el0_64>:
    22f4:	d10403ff 	sub	sp, sp, #0x100
    22f8:	a90007e0 	stp	x0, x1, [sp]
    22fc:	a9010fe2 	stp	x2, x3, [sp, #16]
    2300:	a90217e4 	stp	x4, x5, [sp, #32]
    2304:	a9031fe6 	stp	x6, x7, [sp, #48]
    2308:	a90427e8 	stp	x8, x9, [sp, #64]
    230c:	a9052fea 	stp	x10, x11, [sp, #80]
    2310:	a90637ec 	stp	x12, x13, [sp, #96]
    2314:	a9073fee 	stp	x14, x15, [sp, #112]
    2318:	a90847f0 	stp	x16, x17, [sp, #128]
    231c:	a9094ff2 	stp	x18, x19, [sp, #144]
    2320:	a90a57f4 	stp	x20, x21, [sp, #160]
    2324:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2328:	a90c67f8 	stp	x24, x25, [sp, #192]
    232c:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2330:	a90e77fc 	stp	x28, x29, [sp, #224]
    2334:	f9007bfe 	str	x30, [sp, #240]
    2338:	d2800160 	mov	x0, #0xb                   	// #11
    233c:	d5385201 	mrs	x1, esr_el1
    2340:	d5384022 	mrs	x2, elr_el1
    2344:	97fff948 	bl	864 <show_invalid_entry_message>
    2348:	1400007d 	b	253c <err_hang>

000000000000234c <sync_invalid_el0_32>:
    234c:	d10403ff 	sub	sp, sp, #0x100
    2350:	a90007e0 	stp	x0, x1, [sp]
    2354:	a9010fe2 	stp	x2, x3, [sp, #16]
    2358:	a90217e4 	stp	x4, x5, [sp, #32]
    235c:	a9031fe6 	stp	x6, x7, [sp, #48]
    2360:	a90427e8 	stp	x8, x9, [sp, #64]
    2364:	a9052fea 	stp	x10, x11, [sp, #80]
    2368:	a90637ec 	stp	x12, x13, [sp, #96]
    236c:	a9073fee 	stp	x14, x15, [sp, #112]
    2370:	a90847f0 	stp	x16, x17, [sp, #128]
    2374:	a9094ff2 	stp	x18, x19, [sp, #144]
    2378:	a90a57f4 	stp	x20, x21, [sp, #160]
    237c:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2380:	a90c67f8 	stp	x24, x25, [sp, #192]
    2384:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2388:	a90e77fc 	stp	x28, x29, [sp, #224]
    238c:	f9007bfe 	str	x30, [sp, #240]
    2390:	d2800180 	mov	x0, #0xc                   	// #12
    2394:	d5385201 	mrs	x1, esr_el1
    2398:	d5384022 	mrs	x2, elr_el1
    239c:	97fff932 	bl	864 <show_invalid_entry_message>
    23a0:	14000067 	b	253c <err_hang>

00000000000023a4 <irq_invalid_el0_32>:
    23a4:	d10403ff 	sub	sp, sp, #0x100
    23a8:	a90007e0 	stp	x0, x1, [sp]
    23ac:	a9010fe2 	stp	x2, x3, [sp, #16]
    23b0:	a90217e4 	stp	x4, x5, [sp, #32]
    23b4:	a9031fe6 	stp	x6, x7, [sp, #48]
    23b8:	a90427e8 	stp	x8, x9, [sp, #64]
    23bc:	a9052fea 	stp	x10, x11, [sp, #80]
    23c0:	a90637ec 	stp	x12, x13, [sp, #96]
    23c4:	a9073fee 	stp	x14, x15, [sp, #112]
    23c8:	a90847f0 	stp	x16, x17, [sp, #128]
    23cc:	a9094ff2 	stp	x18, x19, [sp, #144]
    23d0:	a90a57f4 	stp	x20, x21, [sp, #160]
    23d4:	a90b5ff6 	stp	x22, x23, [sp, #176]
    23d8:	a90c67f8 	stp	x24, x25, [sp, #192]
    23dc:	a90d6ffa 	stp	x26, x27, [sp, #208]
    23e0:	a90e77fc 	stp	x28, x29, [sp, #224]
    23e4:	f9007bfe 	str	x30, [sp, #240]
    23e8:	d28001a0 	mov	x0, #0xd                   	// #13
    23ec:	d5385201 	mrs	x1, esr_el1
    23f0:	d5384022 	mrs	x2, elr_el1
    23f4:	97fff91c 	bl	864 <show_invalid_entry_message>
    23f8:	14000051 	b	253c <err_hang>

00000000000023fc <fiq_invalid_el0_32>:
    23fc:	d10403ff 	sub	sp, sp, #0x100
    2400:	a90007e0 	stp	x0, x1, [sp]
    2404:	a9010fe2 	stp	x2, x3, [sp, #16]
    2408:	a90217e4 	stp	x4, x5, [sp, #32]
    240c:	a9031fe6 	stp	x6, x7, [sp, #48]
    2410:	a90427e8 	stp	x8, x9, [sp, #64]
    2414:	a9052fea 	stp	x10, x11, [sp, #80]
    2418:	a90637ec 	stp	x12, x13, [sp, #96]
    241c:	a9073fee 	stp	x14, x15, [sp, #112]
    2420:	a90847f0 	stp	x16, x17, [sp, #128]
    2424:	a9094ff2 	stp	x18, x19, [sp, #144]
    2428:	a90a57f4 	stp	x20, x21, [sp, #160]
    242c:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2430:	a90c67f8 	stp	x24, x25, [sp, #192]
    2434:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2438:	a90e77fc 	stp	x28, x29, [sp, #224]
    243c:	f9007bfe 	str	x30, [sp, #240]
    2440:	d28001c0 	mov	x0, #0xe                   	// #14
    2444:	d5385201 	mrs	x1, esr_el1
    2448:	d5384022 	mrs	x2, elr_el1
    244c:	97fff906 	bl	864 <show_invalid_entry_message>
    2450:	1400003b 	b	253c <err_hang>

0000000000002454 <error_invalid_el0_32>:
    2454:	d10403ff 	sub	sp, sp, #0x100
    2458:	a90007e0 	stp	x0, x1, [sp]
    245c:	a9010fe2 	stp	x2, x3, [sp, #16]
    2460:	a90217e4 	stp	x4, x5, [sp, #32]
    2464:	a9031fe6 	stp	x6, x7, [sp, #48]
    2468:	a90427e8 	stp	x8, x9, [sp, #64]
    246c:	a9052fea 	stp	x10, x11, [sp, #80]
    2470:	a90637ec 	stp	x12, x13, [sp, #96]
    2474:	a9073fee 	stp	x14, x15, [sp, #112]
    2478:	a90847f0 	stp	x16, x17, [sp, #128]
    247c:	a9094ff2 	stp	x18, x19, [sp, #144]
    2480:	a90a57f4 	stp	x20, x21, [sp, #160]
    2484:	a90b5ff6 	stp	x22, x23, [sp, #176]
    2488:	a90c67f8 	stp	x24, x25, [sp, #192]
    248c:	a90d6ffa 	stp	x26, x27, [sp, #208]
    2490:	a90e77fc 	stp	x28, x29, [sp, #224]
    2494:	f9007bfe 	str	x30, [sp, #240]
    2498:	d28001e0 	mov	x0, #0xf                   	// #15
    249c:	d5385201 	mrs	x1, esr_el1
    24a0:	d5384022 	mrs	x2, elr_el1
    24a4:	97fff8f0 	bl	864 <show_invalid_entry_message>
    24a8:	14000025 	b	253c <err_hang>

00000000000024ac <el1_irq>:
    24ac:	d10403ff 	sub	sp, sp, #0x100
    24b0:	a90007e0 	stp	x0, x1, [sp]
    24b4:	a9010fe2 	stp	x2, x3, [sp, #16]
    24b8:	a90217e4 	stp	x4, x5, [sp, #32]
    24bc:	a9031fe6 	stp	x6, x7, [sp, #48]
    24c0:	a90427e8 	stp	x8, x9, [sp, #64]
    24c4:	a9052fea 	stp	x10, x11, [sp, #80]
    24c8:	a90637ec 	stp	x12, x13, [sp, #96]
    24cc:	a9073fee 	stp	x14, x15, [sp, #112]
    24d0:	a90847f0 	stp	x16, x17, [sp, #128]
    24d4:	a9094ff2 	stp	x18, x19, [sp, #144]
    24d8:	a90a57f4 	stp	x20, x21, [sp, #160]
    24dc:	a90b5ff6 	stp	x22, x23, [sp, #176]
    24e0:	a90c67f8 	stp	x24, x25, [sp, #192]
    24e4:	a90d6ffa 	stp	x26, x27, [sp, #208]
    24e8:	a90e77fc 	stp	x28, x29, [sp, #224]
    24ec:	f9007bfe 	str	x30, [sp, #240]
    24f0:	97fff8ee 	bl	8a8 <handle_irq>
    24f4:	a94007e0 	ldp	x0, x1, [sp]
    24f8:	a9410fe2 	ldp	x2, x3, [sp, #16]
    24fc:	a94217e4 	ldp	x4, x5, [sp, #32]
    2500:	a9431fe6 	ldp	x6, x7, [sp, #48]
    2504:	a94427e8 	ldp	x8, x9, [sp, #64]
    2508:	a9452fea 	ldp	x10, x11, [sp, #80]
    250c:	a94637ec 	ldp	x12, x13, [sp, #96]
    2510:	a9473fee 	ldp	x14, x15, [sp, #112]
    2514:	a94847f0 	ldp	x16, x17, [sp, #128]
    2518:	a9494ff2 	ldp	x18, x19, [sp, #144]
    251c:	a94a57f4 	ldp	x20, x21, [sp, #160]
    2520:	a94b5ff6 	ldp	x22, x23, [sp, #176]
    2524:	a94c67f8 	ldp	x24, x25, [sp, #192]
    2528:	a94d6ffa 	ldp	x26, x27, [sp, #208]
    252c:	a94e77fc 	ldp	x28, x29, [sp, #224]
    2530:	f9407bfe 	ldr	x30, [sp, #240]
    2534:	910403ff 	add	sp, sp, #0x100
    2538:	d69f03e0 	eret

000000000000253c <err_hang>:
    253c:	14000000 	b	253c <err_hang>

0000000000002540 <memzero>:
    2540:	f800841f 	str	xzr, [x0], #8
    2544:	f1002021 	subs	x1, x1, #0x8
    2548:	54ffffcc 	b.gt	2540 <memzero>
    254c:	d65f03c0 	ret
