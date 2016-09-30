## -*- asm -*- ##############################################################
#                                                                           #
#                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                  #
#                                                                           #
#                               H A N D L E R                               #
#                                                                           #
#                               Assembly File                               #
#                                                                           #
#                      Copyright (C) 2012-2013 AdaCore                      #
#                                                                           #
#  GNAT is free software;  you can  redistribute it  and/or modify it under #
#  terms of the  GNU General Public License as published  by the Free Soft- #
#  ware  Foundation;  either version 3,  or (at your option) any later ver- #
#  sion.  GNAT is distributed in the hope that it will be useful, but WITH- #
#  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY #
#  or FITNESS FOR A PARTICULAR PURPOSE.                                     #
#                                                                           #
#  As a special exception under Section 7 of GPL version 3, you are granted #
#  additional permissions described in the GCC Runtime Library Exception,   #
#  version 3.1, as published by the Free Software Foundation.               #
#                                                                           #
#  You should have received a copy of the GNU General Public License and    #
#  a copy of the GCC Runtime Library Exception along with this program;     #
#  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    #
#  <http://www.gnu.org/licenses/>.                                          #
#                                                                           #
#############################################################################

	.syntax unified
        .arch armv6-m
        .thumb

	/* Vector table installed by the ravenscar runtime. According to
	   the arm v7m manual (B1.5.3 The vector table):

	   The Vector table must be naturally aligned to a power of two whose
	   alignment value is greater than or equal to (Number of Exceptions
	   supported x 4), with a minimum alignment of 128 bytes.

	   There are 47 entries, and as 47 * 4 = 188 the table should be
	   aligned to 256 = 2 ** 8.

	   ??? Because of this alignment constraint, we should avoid the
	   hole in memory before this table. */

	.text
	.globl	__vectors
	.p2align 8
__vectors:
	.word   0                    /* stack top address */
	.word   fault                /* 1 Reset.  */
	.word   fault                /* 2 NMI.  */
	.word   fault	             /* 3 Hard fault. */
	.word   0                    /* 4 reserved.  */
	.word   0                    /* 5 reserved.  */
	.word   0                    /* 6 reserved.  */
	.word   0                    /* 7 reserved.  */
	.word   0                    /* 8 reserved.  */
	.word   0                    /* 9 reserved.  */
	.word   0                    /* 10 reserved.  */
	.word   __gnat_sv_call_trap  /* 11 SVCall.  */
	.word   fault                /* 12 Reserved for Debug.  */
	.word   fault                /* 13 Reserved.  */
	.word   __gnat_pend_sv_trap  /* 14 PendSV.  */
	.word   __gnat_sys_tick_trap /* 15 Systick.  */
	.word   __gnat_irq_trap      /* 16 IRQ0.  */
	.word   __gnat_irq_trap      /* 17 IRQ1.  */
	.word   __gnat_irq_trap      /* 18 IRQ2.  */
	.word   __gnat_irq_trap      /* 19 IRQ3.  */
	.word   __gnat_irq_trap      /* 20 IRQ4.  */
	.word   __gnat_irq_trap      /* 21 IRQ5.  */
	.word   __gnat_irq_trap      /* 22 IRQ6.  */
	.word   __gnat_irq_trap      /* 23 IRQ7.  */
	.word   __gnat_irq_trap      /* 24 IRQ8.  */
	.word   __gnat_irq_trap      /* 25 IRQ9.  */
	.word   __gnat_irq_trap      /* 26 IRQ10.  */
	.word   __gnat_irq_trap      /* 27 IRQ11.  */
	.word   __gnat_irq_trap      /* 28 IRQ12.  */
	.word   __gnat_irq_trap      /* 29 IRQ13.  */
	.word   __gnat_irq_trap      /* 30 IRQ14.  */
	.word   __gnat_irq_trap      /* 31 IRQ15.  */
	.word   __gnat_irq_trap      /* 32 IRQ16.  */
	.word   __gnat_irq_trap      /* 33 IRQ17.  */
	.word   __gnat_irq_trap      /* 34 IRQ18.  */
	.word   __gnat_irq_trap      /* 35 IRQ19.  */
	.word   __gnat_irq_trap      /* 36 IRQ20.  */
	.word   __gnat_irq_trap      /* 37 IRQ21.  */
	.word   __gnat_irq_trap      /* 38 IRQ22.  */
	.word   __gnat_irq_trap      /* 39 IRQ23.  */
	.word   __gnat_irq_trap      /* 40 IRQ24.  */
	.word   __gnat_irq_trap      /* 41 IRQ25.  */
	.word   __gnat_irq_trap      /* 42 IRQ26.  */
	.word   __gnat_irq_trap      /* 43 IRQ27.  */
	.word   __gnat_irq_trap      /* 44 IRQ28.  */
	.word   __gnat_irq_trap      /* 45 IRQ29.  */
	.word   __gnat_irq_trap      /* 46 IRQ30.  */
	.word   __gnat_irq_trap      /* 47 IRQ31.  */

	.text

.weak __gnat_irq_trap
.type __gnat_irq_trap, %function
__gnat_irq_trap:
0:	b	0b

	.size __gnat_irq_trap, . - __gnat_irq_trap

	.thumb_func
.weak ____gnat_sv_call_trap
.type __gnat_sv_call_trap, %function
__gnat_sv_call_trap:
0:	b	0b
	.size	__gnat_sv_call_trap, . - __gnat_sv_call_trap

	.thumb_func
.weak __gnat_pend_sv_trap
.type __gnat_pend_sv_trap, %function
__gnat_pend_sv_trap:
0:	b	0b
	.size	__gnat_pend_sv_trap, . - __gnat_pend_sv_trap

.weak __gnat_sys_tick_trap
.type __gnat_sys_tick_trap, %function
__gnat_sys_tick_trap:

	.thumb_func
fault:	b	fault
