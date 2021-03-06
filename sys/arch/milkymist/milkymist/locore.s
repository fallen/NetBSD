/*	$NetBSD: $	*/

/*
 * LatticeMico32 C startup code.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <lm32/asm.h>
#include "assym.h"

/* Exception handlers - Must be 32 bytes long. */
.section	.text, "ax", @progbits
.global		_start
.type		_start,@function
.global		start
.type		start,@function

start:
_bootstrap:
	xor	r0, r0, r0
	wcsr	PSW, r0
/*	mvhi	r1, hi(_reset_handler - _bootstrap)
	ori	r1, r1, lo(_reset_handler) */
	mvhi	r1, 0x4000
	ori	r1, r1, lo(_start)
	wcsr	EBA, r1
	xor	r2, r2, r2
	bi	_crt0
	nop

_memory_store_area:
.word _memory_store_area - start + 0x40000000 +8

.org 0x1000 /* we reserve one page of memory storage to save registers during (nested) exceptions */

_start:
kernel_text:
_reset_handler:
	xor	r0, r0, r0
	wcsr	PSW, r0
	mvhi	r1, hi(_reset_handler)
	ori	r1, r1, lo(_reset_handler)
	wcsr	EBA, r1
	xor	r2, r2, r2
	bi	_crt0
	nop

_breakpoint_handler:
	bi _breakpoint_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_instruction_bus_error_handler:
	bi _instruction_bus_error_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_watchpoint_hander:
	bi _watchpoint_hander
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_data_bus_error_handler:
	bi _data_bus_error_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_divide_by_zero_handler:
	bi _divide_by_zero_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_interrupt_handler:
  bi _real_interrupt_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_syscall_handler:
	bi	_call_syscall_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_ENTRY(_itlb_miss_handler)
	bi	_fake_itlb_miss_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_ENTRY(_dtlb_miss_handler)
	bi	_fake_dtlb_miss_handler
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_ENTRY(_dtlb_fault_handler)
	rcsr	r0, TLBPADDR
	ori	r0, r0, 1
	wcsr	TLBPADDR, r0
	xor	r0, r0, r0 /* restore r0 to 0 */
	eret
	nop
	nop
	nop


_privilege_fault_handler:
	eret
	nop
	nop
	nop
	nop
	nop
	nop
	nop

macaddress:
	.byte 0x10
	.byte 0xe2
	.byte 0xd5
	.byte 0x00
	.byte 0x00
	.byte 0x00

	/* padding to align to a 32-bit boundary */
	.byte 0x00
	.byte 0x00

_ENTRY(_call_syscall_handler)
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r0, (r0+0)
	sw	(r0+0), r1
	sw	(r0+4), r2
	sw	(r0+8), r3
	sw	(r0+12), r4
	sw	(r0+16), r5
	sw	(r0+20), r6
	sw	(r0+24), r7
	sw	(r0+28), r8
	sw	(r0+32), r9
	sw	(r0+36), r10
	sw	(r0+40), r11
	sw	(r0+44), r12
	sw	(r0+48), r13
	sw	(r0+52), r14
	sw	(r0+56), r15
	sw	(r0+60), r16
	sw	(r0+64), r17
	sw	(r0+68), r18
	sw	(r0+72), r19
	sw	(r0+76), r20
	sw	(r0+80), r21
	sw	(r0+84), r22
	sw	(r0+88), r23
	sw	(r0+92), r24
	sw	(r0+96), r25
	sw	(r0+100), gp
	sw	(r0+104), fp
	sw	(r0+108), sp
	sw	(r0+112), ra
	sw	(r0+116), ea
	sw	(r0+120), ba
	rcsr	r3, PSW
	sw	(r0+128), r3
	xor	r0, r0, r0 /* restore r0 value to 0 */
  /* now update memory_store_area in case of nested tlb miss */
	mvhi	r1, 0x4000
	ori	r1, r1, lo(_memory_store_area)
	lw	r2, (r1+0)
	mv	r5, r2
	addi	r2, r2, 132
	sw	(r1+0), r2

	mvhi	ea, hi(3f)
	ori	ea, ea, lo(3f)
	ori	r3, r3, 0x90 /* PSW_EDTLBE | PSW_EITLBE */
	mvhi	r4, 0xFFFF
	ori	r4, r4, 0xFBFF
	and	r3, r4, r3 /* r3 &= ~PSW_EUSR */
	wcsr	PSW, r3
	eret
3:
	GET_CPUVAR(r2, CURLWP)
	lw	r6, (r2+L_PCB)
	lw	sp, (r6+PCB_KSP) /* load kernel stack pointer */
2:
	lw	r2, (r2+L_PROC)
	lw	r2, (r2+P_MD_SYSCALL)

	mv	r1, r5

	/* call syscall() (in r2) with MMU ON */
	call	r2

	mvhi	r1, hi(_memory_store_area)
	ori	r1, r1, lo(_memory_store_area)
	lw	r2, (r1+0)
	addi	r2, r2, -132
	sw	(r1+0), r2
	mvhi	r3, 0x4000
	sub	r2, r2, r3
	mvhi	r3, 0xc000
	add	r2, r2, r3
	mv	r0, r2
	lw	r1, (r0+128)
	wcsr	PSW, r1
	lw	r1, (r0+0)
	lw	r2, (r0+4)
	lw	r3, (r0+8)
	lw	r4, (r0+12)
	lw	r5, (r0+16)
	lw	r6, (r0+20)
	lw	r7, (r0+24)
	lw	r8, (r0+28)
	lw	r9, (r0+32)
	lw	r10, (r0+36)
	lw	r11, (r0+40)
	lw	r12, (r0+44)
	lw	r13, (r0+48)
	lw	r14, (r0+52)
	lw	r15, (r0+56)
	lw	r16, (r0+60)
	lw	r17, (r0+64)
	lw	r18, (r0+68)
	lw	r19, (r0+72)
	lw	r20, (r0+76)
	lw	r21, (r0+80)
	lw	r22, (r0+84)
	lw	r23, (r0+88)
	lw	r24, (r0+92)
	lw	r25, (r0+96)
	lw	gp, (r0+100)
	lw	fp, (r0+104)
	lw	sp, (r0+108)
	lw	ra, (r0+112)
	lw	ea, (r0+116)
	lw	ba, (r0+120)
	xor	r0, r0, r0 /* restore r0 value to 0 */
	eret

_ENTRY(_fake_itlb_miss_handler)
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw 	r0, (r0+0)
	sw	(r0+0), r1
	sw	(r0+4), r2
	lw	r1, (r0+-4) /* r1 = memory_store_area.first_jump_to_vaddr_done */
	xor	r0, r0, r0 /* restore r0 to 0 */
	be	r1, r0, 1f
	
	rcsr	r1, TLBPADDR
	
	mvhi	r2, 0xffff
	ori	r2, r2, 0xf000
	and	r1, r1, r2 /* r1 &= ~(PG_MASK) */  
	mvhi	r2, 0xc000
	sub	r1, r1, r2
	mvhi	r2, 0x4000
	add	r1, r1, r2
	
	wcsr	TLBPADDR, r1

	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r0, (r0+0)
	lw	r1, (r0+0)
	lw	r2, (r0+4)
	xor	r0, r0, r0 /* restore r0 to 0 */
	eret

1:
	mvhi	r1, 0x4000
	sub	ea, ea, r1
	mvhi	r1, 0xc000
	add	ea, ea, r1
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	ori	r2, r2, 0x42
	lw	r0, (r0+0)
	sw	(r0+-4), r2 /* memory_store_area.first_jump_to_vaddr_done = true */
	lw	r1, (r0+0)
	lw	r2, (r0+4)
	xor	r0, r0, r0 /* restore r0 to 0 */
	eret

_ENTRY(_fake_dtlb_miss_handler)
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r0, (r0+0)
	sw	(r0+0), r1
	sw	(r0+4), r2
	xor	r0, r0, r0 /* restore r0 to 0 */

	rcsr	r1, TLBPADDR
	
	mvhi	r2, 0xffff
	ori	r2, r2, 0xf000
	and	r1, r1, r2 /* r1 &= ~(PG_MASK) */  
	mvhi	r2, 0xc000
	sub	r1, r1, r2
	mvhi	r2, 0x4000
	add	r1, r1, r2
	ori	r1, r1, 1 /* writting to DTLB */ 
	wcsr	TLBPADDR, r1

	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r0, (r0+0)
	lw	r1, (r0+0)
	lw	r2, (r0+4)
	xor	r0, r0, r0 /* restore r0 to 0 */
	eret

_ENTRY(_real_interrupt_handler)
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r0, (r0+0)
	sw	(r0+0), r1
	sw	(r0+4), r2
	sw	(r0+8), r3
	sw	(r0+12), r4
	sw	(r0+16), r5
	sw	(r0+20), sp
	sw	(r0+24), ea
	rcsr	r3, PSW
	sw	(r0+28), r3
	sw	(r0+32), r24 /* GET_CPUVAR_MMUOFF overwrites r24 and r25, beware */
	sw	(r0+36), r25
	xor	r0, r0, r0 /* restore r0 value to 0 */
  /* now update memory_store_area in case of nested tlb miss */
	mvhi	r1, 0x4000
	ori	r1, r1, lo(_memory_store_area)
	lw	r2, (r1+0)
	mv	r5, r2
	addi	r2, r2, 40
	sw	(r1+0), r2


	andi	r4, r3, PSW_EUSR

	/* enable MMU */
	rcsr	r1, PSW
	ori	r1, r1, 0x90 /* EITLBE | EDTLBE */
	mvhi	r2, 0xffff
	ori	r2, r2, 0xfbfd
	and	r1, r1, r2 /* psw &=  ~(PSW.EIE | PSW.EUSR) */
	wcsr	PSW, r1
	mvhi	ea, hi(2f)
	ori	ea, ea, lo(2f)
	eret
2:
	be	r4, r0, 1f
	GET_CPUVAR(r4, CURLWP)
	lw	r4, (r4+L_PCB)
	lw	sp, (r4+PCB_KSP) /* load kernel stack pointer */
1:
	addi	sp, sp, -(PCB_REGS+4*_REG_BA) /* allocate space on the stack */
	sw	(sp+PCB_REGS+4*_REG_R6),  r6
	sw	(sp+PCB_REGS+4*_REG_R7),  r7
	sw	(sp+PCB_REGS+4*_REG_R8),  r8
	sw	(sp+PCB_REGS+4*_REG_R9),  r9
	sw	(sp+PCB_REGS+4*_REG_R10), r10
	sw	(sp+PCB_REGS+4*_REG_R11), r11
	sw	(sp+PCB_REGS+4*_REG_R12), r12
	sw	(sp+PCB_REGS+4*_REG_R13), r13
	sw	(sp+PCB_REGS+4*_REG_R14), r14
	sw	(sp+PCB_REGS+4*_REG_R15), r15
	sw	(sp+PCB_REGS+4*_REG_R16), r16
	sw	(sp+PCB_REGS+4*_REG_R17), r17
	sw	(sp+PCB_REGS+4*_REG_R18), r18
	sw	(sp+PCB_REGS+4*_REG_R19), r19
	sw	(sp+PCB_REGS+4*_REG_R20), r20
	sw	(sp+PCB_REGS+4*_REG_R21), r21
	sw	(sp+PCB_REGS+4*_REG_R22), r22
	sw	(sp+PCB_REGS+4*_REG_R23), r23
	sw	(sp+PCB_REGS+4*_REG_GP),  gp
	sw	(sp+PCB_REGS+4*_REG_FP),  fp
	sw	(sp+PCB_REGS+4*_REG_RA),  ra
	sw	(sp+PCB_REGS+4*_REG_BA),  ba
	lw	r8, (r5+0) /* r1 */
	sw	(sp+PCB_REGS+4*_REG_R1),  r8
	lw	r8, (r5+4) /* r2 */
	sw	(sp+PCB_REGS+4*_REG_R2),  r8
	lw	r8, (r5+8) /* r3 */
	sw	(sp+PCB_REGS+4*_REG_R3),  r8
	lw	r8, (r5+12) /* r4 */
	sw	(sp+PCB_REGS+4*_REG_R4),  r8
	lw	r8, (r5+16) /* r5 */
	sw	(sp+PCB_REGS+4*_REG_R5),  r8
	lw	r8, (r5+20) /* sp */
	sw	(sp+PCB_REGS+4*_REG_SP),  r8
	lw	r8, (r5+32) /* r24 */
	sw	(sp+PCB_REGS+4*_REG_R24),  r8
	lw	r8, (r5+36) /* r25 */
	sw	(sp+PCB_REGS+4*_REG_R25),  r8
	lw	r8, (r5+24) /* ea */
	sw	(sp+PCB_REGS+4*_REG_EA),  r8

	rcsr	r1, IP
	mvhi	ea, hi(__isr) /* function we want to call */
	ori	ea, ea, lo(__isr)
	mvhi	r2, hi(1f)                          /* where we want to return back to */
	ori	r2, r2, lo(1f)
	mv	r3, r5 /* arg3 is trapframe */
	calli	__isr
  

1:
/*	GET_CPUVAR(r4, CURLWP) */
/*	lw	r4, (r4+L_PCB) */
/*	lw	sp, (r4+PCB_KSP)*/ /* load kernel stack pointer */
	mvhi	r1, hi(_memory_store_area)
	ori	r1, r1, lo(_memory_store_area)
	lw	r2, (r1+0)
	addi	r2, r2, -40
	sw	(r1+0), r2
	mvhi	r3, 0x4000
	sub	r2, r2, r3
	mvhi	r3, 0xc000
	add	r2, r2, r3
	lw	r3, (r2+28)
	wcsr	PSW, r3
	lw	r1,  (sp+PCB_REGS+4*_REG_R1)
	lw	r2,  (sp+PCB_REGS+4*_REG_R2)
	lw	r3,  (sp+PCB_REGS+4*_REG_R3)
	lw	r4,  (sp+PCB_REGS+4*_REG_R4)
	lw	r5,  (sp+PCB_REGS+4*_REG_R5)
	lw	r6,  (sp+PCB_REGS+4*_REG_R6)
	lw	r7,  (sp+PCB_REGS+4*_REG_R7)
	lw	r8,  (sp+PCB_REGS+4*_REG_R8)
	lw	r9,  (sp+PCB_REGS+4*_REG_R9)
	lw	r10, (sp+PCB_REGS+4*_REG_R10)
	lw	r11, (sp+PCB_REGS+4*_REG_R11)
	lw	r12, (sp+PCB_REGS+4*_REG_R12)
	lw	r13, (sp+PCB_REGS+4*_REG_R13)
	lw	r14, (sp+PCB_REGS+4*_REG_R14)
	lw	r15, (sp+PCB_REGS+4*_REG_R15)
	lw	r16, (sp+PCB_REGS+4*_REG_R16)
	lw	r17, (sp+PCB_REGS+4*_REG_R17)
	lw	r18, (sp+PCB_REGS+4*_REG_R18)
	lw	r19, (sp+PCB_REGS+4*_REG_R19)
	lw	r20, (sp+PCB_REGS+4*_REG_R20)
	lw	r21, (sp+PCB_REGS+4*_REG_R21)
	lw	r22, (sp+PCB_REGS+4*_REG_R22)
	lw	r23, (sp+PCB_REGS+4*_REG_R23)
	lw	r24, (sp+PCB_REGS+4*_REG_R24)
	lw	r25, (sp+PCB_REGS+4*_REG_R25)
	lw	gp,  (sp+PCB_REGS+4*_REG_GP)
	lw	fp,  (sp+PCB_REGS+4*_REG_FP)
	lw	ra,  (sp+PCB_REGS+4*_REG_RA)
	lw	ea,  (sp+PCB_REGS+4*_REG_EA)
	lw	ba,  (sp+PCB_REGS+4*_REG_BA)
	lw	sp,  (sp+PCB_REGS+4*_REG_SP)
	eret

_ENTRY(_real_tlb_miss_handler)
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r0, (r0+0)
	sw	(r0+0),   r1
	sw	(r0+4),   r2
	sw	(r0+8),   r3
	sw	(r0+12),  r4
	sw	(r0+16),  r5
	sw	(r0+20),  r6
	sw	(r0+24),  r7
	sw	(r0+28),  r8
	sw	(r0+32),  r9
	sw	(r0+36),  r10
	sw	(r0+40),  r11
	sw	(r0+44),  r12
	sw	(r0+48),  r13
	sw	(r0+52),  r14
	sw	(r0+56),  r15
	sw	(r0+60),  r16
	sw	(r0+64),  r17
	sw	(r0+68),  r18
	sw	(r0+72),  r19
	sw	(r0+76),  r20
	sw	(r0+80),  r21
	sw	(r0+84),  r22
	sw	(r0+88),  r23
	sw	(r0+92),  r24
	sw	(r0+96),  r25
	sw	(r0+100), gp
	sw	(r0+104), fp
	sw	(r0+108), sp
	sw	(r0+112), ra
	sw	(r0+116), ea
	sw	(r0+120), ba
	rcsr	r3, PSW
	sw	(r0+128), r3
	xor	r0, r0, r0 /* restore r0 value to 0 */
	/* now update memory_store_area in case of nested tlb miss */
	mvhi	r1, 0x4000
	ori	r1, r1, lo(_memory_store_area)
	lw	r2, (r1+0)
	addi	r2, r2, 132
	sw	(r1+0), r2
	
	rcsr	r1, TLBVADDR
	rcsr	r2, TLBPADDR
	andi	r3, r3, PSW_EUSR /* r3 &= PSW_EUSR */
	bne	r3, r0, we_come_from_user_space
	mvhi	r3, 0xffff
	ori	r3, r3, 0xf07f /* r3 = ~(TLBVADDR_ASID_MASK); */
	and	r1, r1, r3
	wcsr	TLBVADDR, r1
	mvhi	r3, 0xc800
	cmpgeu	r4, r1, r3
	bne	r4, r0, out_of_ram_window
	mvhi	r3, 0xc000
	cmpgu	r4, r3, r1
	bne	r4, r0, out_of_ram_window
	mvhi	r3, 0xc000
	sub	r1, r1, r3
	mvhi	r3, 0x4000
	add	r1, r1, r3
	wcsr	TLBPADDR, r1
	bi	1f /* let's return to what we were doing */

out_of_ram_window:
	rcsr	r1, TLBVADDR
	mvhi	r4, hi(_C_LABEL(cpu_info_store))
	ori	r4, r4, lo(_C_LABEL(cpu_info_store))
	mvhi	r5, 0xc000
	sub	r4, r4, r5
	mvhi	r5, 0x4000
	add	r4, r4, r5
	lw	r4, (r4+CPU_INFO_KERNEL_SEGTAB)
	srui	r5, r1, SEGSHIFT
	sli	r5, r5, 2
	add	r6, r4, r5
	
	calli	check_page_table
	be	r2, r0, 1f

we_come_from_user_space:
	mvhi	r4, hi(_C_LABEL(cpu_info_store))
	ori	r4, r4, lo(_C_LABEL(cpu_info_store))
	mvhi	r5, 0xc000
	sub	r4, r4, r5
	mvhi	r5, 0x4000
	add	r4, r4, r5
	lw	r4, (r4+CPU_INFO_USER_SEGTAB) /* r4 = curcpu()->ci_pmap_user_segtab; */
	srui	r5, r1, SEGSHIFT
	sli	r5, r5, 2
	add	r6, r4, r5
	
	calli	check_page_table
	be	r2, r0, 1f

goto_trap:
	mvhi	r2, 0x4000
	ori	r2, r2, lo(_memory_store_area)
	lw	r2, (r2+0)
	addi	r2, r2, -132
	mvhi	ea, hi(_C_LABEL(lm32_trap))
	ori	ea, ea, lo(_C_LABEL(lm32_trap))
	xor	r3, r3, r3
	ori	r3, r3, 0x90 /* EDTLBE | EITLBE */
	wcsr	PSW, r3
	mvhi	r4, 0xc000
	mvhi	r3, hi(1f)
	ori	r3, r3, lo(1f)
	sub	r3, r3, r4
	mvhi	r4, 0x4000
	add	r3, r3, r4
	rcsr	r4, TLBVADDR
	andi	r4, r4, 1
	be	r4, r0, itlb_fault

	/* FIXME: is it a read or a write issue?
	 * for now let's pretend it's a READ
	 */
	mvi	r4, VM_PROT_READ
	bi	trapping

itlb_fault:
	mvi	r4, VM_PROT_EXECUTE

trapping:
	eret

1:
	mvhi	r0, 0x4000
	ori	r0, r0, lo(_memory_store_area)
	lw	r1, (r0+0)
	addi	r1, r1, -132
	sw	(r0+0), r1
	addi	r0, r1, 0 /* we cannot use 'mv' when r0 != 0 */
	lw	r1, (r0+128)
	wcsr	PSW, r1
	lw	r1, (r0+0)
	lw	r2, (r0+4)
	lw	r3, (r0+8)
	lw	r4, (r0+12)
	lw	r5, (r0+16)
	lw	r6, (r0+20)
	lw	r7, (r0+24)
	lw	r8, (r0+28)
	lw	r9, (r0+32)
	lw	r10, (r0+36)
	lw	r11, (r0+40)
	lw	r12, (r0+44)
	lw	r13, (r0+48)
	lw	r14, (r0+52)
	lw	r15, (r0+56)
	lw	r16, (r0+60)
	lw	r17, (r0+64)
	lw	r18, (r0+68)
	lw	r19, (r0+72)
	lw	r20, (r0+76)
	lw	r21, (r0+80)
	lw	r22, (r0+84)
	lw	r23, (r0+88)
	lw	r24, (r0+92)
	lw	r25, (r0+96)
	lw	gp, (r0+100)
	lw	fp, (r0+104)
	lw	sp, (r0+108)
	lw	ra, (r0+112)
	lw	ea, (r0+116)
	lw	ba, (r0+120)
	xor	r0, r0, r0 /* restore r0 value to 0 */
	eret

check_page_table:
	mvhi	r5, 0xc000
	sub	r6, r6, r5
	mvhi	r5, 0x4000
	add	r6, r6, r5
	lw	r7, (r6+0) /* ptp = pm_segtab[vaddr >> SEGSHIFT]; */
	be	r7, r0, ptp_not_found
	
	/* translate the ptp from virt to phy */
	mvhi	r10, 0xc000
	sub	r7, r7, r10
	mvhi	r10, 0x4000
	add 	r7, r7, r10
	
	mvhi	r11, hi(L2_MASK)
	ori	r11, r11, lo(L2_MASK)
	and	r8, r1, r11
	srui	r8, r8, PGSHIFT
	sli	r8, r8, 2
	add	r8, r8, r7
	lw	r9, (r8+0) /* pte = ptp[(vaddr & L2_MASK) >> PGSHIFT] ; */
	
	be	r9, r0, pte_not_found

/* TODO: check for PTE_xX,PTE_xR, PTE_xW before assigning the rights */
/* for now all mappings are read-write-execute */

	andi	r2, r1, 1  /* if (vpfn & 1) { */
	be	r2, r0, not_a_dtlb_miss
	ori	r9, r9, 1 /* pte |= 1; meaning we refresh DTLB */
	mvhi	r2, 0xffff
	ori	r2, r2, 0xfffd
	and	r9, r9, r2 /* pte &= ~(2); clearing Read-Only bit */

not_a_dtlb_miss: /* } */
	wcsr	TLBPADDR, r9
	xor	r2, r2, r2 /* r2 = EXIT_SUCCESS */
	ret

ptp_not_found:
pte_not_found:
	mvi	r2, 1 /* r2 = EXIT_FAILURE */
	ret


_crt0:
	mvhi	r1, 0x4000
	ori	r1, r1, lo(_memory_store_area)
	lw	r2, (r1+0)
	addi	r2, r2, 4
	sw	(r1+0), r2
	/* activate ITLB and DTLB */
	mvi	r1, 0x48
	wcsr	PSW, r1

	/* stack and global pointers 
	* should be initialized
	* by bootloader/BIOS
	*/
	/* Setup stack and global pointer */
	mvhi	sp, hi(_fstack)
	ori	sp, sp, lo(_fstack)
	mvhi	gp, hi(_gp)
	ori	gp, gp, lo(_gp)

	/* Clear BSS */
	mvhi	r1, hi(_fbss)
	ori	r1, r1, lo(_fbss)
	mvhi	r3, hi(_ebss)
	ori	r3, r3, lo(_ebss)
.clearBSS:
	be	r1, r3, .callMain
	sw	(r1+0), r0
	addi	r1, r1, 4
	bi	.clearBSS

.callMain:	
	mv	r1, r2
	mvi	r2, 0
	mvi	r3, 0
	mvhi	r4, hi(milkymist_startup)
	ori	r4, r4, lo(milkymist_startup)
	b	r4

.save_all:
	addi	sp, sp, -56
	sw	(sp+4), r1
	sw	(sp+8), r2
	sw	(sp+12), r3
	sw	(sp+16), r4
	sw	(sp+20), r5
	sw	(sp+24), r6
	sw	(sp+28), r7
	sw	(sp+32), r8
	sw	(sp+36), r9
	sw	(sp+40), r10
	sw	(sp+48), ea
	sw	(sp+52), ba
	/* ra needs to be moved from initial stack location */
	lw	r1, (sp+56)
	sw	(sp+44), r1
	ret

.restore_all_and_eret:
	lw	r1, (sp+4)
	lw	r2, (sp+8)
	lw	r3, (sp+12)
	lw	r4, (sp+16)
	lw	r5, (sp+20)
	lw	r6, (sp+24)
	lw	r7, (sp+28)
	lw	r8, (sp+32)
	lw	r9, (sp+36)
	lw	r10, (sp+40)
	lw	ra, (sp+44)
	lw	ea, (sp+48)
	lw	ba, (sp+52)
	addi	sp, sp, 56
	eret

.section    .rodata, "a", @progbits
page_fault_panic_str:
.asciz "ptp or pte not found"
