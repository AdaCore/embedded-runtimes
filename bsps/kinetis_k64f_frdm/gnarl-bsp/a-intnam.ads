------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                   A D A . I N T E R R U P T S . N A M E S                --
--                                                                          --
--                                  S p e c                                 --
--                                                                          --
--          Copyright (C) 1991-2013, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
------------------------------------------------------------------------------

--  This is the version for Cortex M4F Kinetis K64F targets
with Kinetis_K64F;

package Ada.Interrupts.Names is

   --  All identifiers in this unit are implementation defined

   pragma Implementation_Defined;

   --  Interrupt_ID 0 is reserved and the SysTick interrupt (a core interrupt)
   --  is handled by the runtime like other interrupts. So the first interrupt
   --  is numbered 2. The offset of 2 is reflected in s-bbbosu.adb by the
   --  First_IRQ constant.

   Sys_Tick_Interrupt               : constant Interrupt_ID := 1;
   DMA0_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.DMA0_IRQ) + 2;

   UART0_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.UART0_RX_TX_IRQ) +
     2;

   UART1_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.UART1_RX_TX_IRQ) +
     2;

   UART2_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.UART2_RX_TX_IRQ) +
     2;

   UART3_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.UART3_RX_TX_IRQ) +
     2;

   UART4_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.UART4_RX_TX_IRQ) +
     2;

   UART5_Interrupt                   : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.UART5_RX_TX_IRQ) +
     2;

   ENET0_Transmit_Interrupt          : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (
        Kinetis_K64F.ENET_Transmit_IRQ) + 2;

   ENET0_Receive_Interrupt           : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.ENET_Receive_IRQ) +
     2;

   ENET0_Error_Interrupt             : constant Interrupt_ID :=
     Kinetis_K64F.External_Interrupt_Type'Pos (Kinetis_K64F.ENET_Error_IRQ) +
     2;

   --  ...

end Ada.Interrupts.Names;
