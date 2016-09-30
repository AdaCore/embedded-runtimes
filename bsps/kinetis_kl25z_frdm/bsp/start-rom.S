## -*- asm -*- ##############################################################
#                                                                           #
#                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                  #
#                                                                           #
#                                 S T A R T                                 #
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

	/* This is the initial vector table and also the one that is used by
	   the zfp runtime. Ravenscar runtimes install its own table (using
	   VTOR register) defined in handler.S.  */
	.section .vectors,"a"
        .align 2
__vectors0:
	.long   __stack_end /* stack top address */
	.long   _start_rom  /* 1 Reset */
	.long   hang        /* 2 NMI */
	.long   hang        /* 3 HardFault */

        /* Flash Configuration */
        .section .FlashConfig, "a"
        .long 0xFFFFFFFF
        .long 0xFFFFFFFF
        .long 0xFFFFFFFF
        .long 0xFFFFFFFE

	.text
        .thumb

	.thumb_func
        .align 2
	.globl _start_rom
_start_rom:
        /*
         * NOTE: Initializing the watchdog must be done first, otherwise the
         * watchdog will fire.
         */
        bl watchdog_timer__initialize

       	/* Copy .data */
        ldr     r0, =__data_start
	ldr     r1, =__data_end
        ldr     r2, =__data_load
0:	cmp     r0, r1
        beq     1f
        ldr	r3, [r2]
        adds    r2, r2, #4
	str	r3, [r0]
        adds    r0, r0, #4
	b	0b

1:
	/* Clear .bss */
        ldr     r0, =__bss_start
	ldr     r1, =__bss_end
        movs	r2, #0
0:	cmp     r0, r1
        beq     1f
        str	r2, [r0]
        adds    r0, r0, #4
        b	0b

1:
        bl	microcontroller_clocks__initialize
        bl      reset_counter__update
	bl	main

hang:   b .
