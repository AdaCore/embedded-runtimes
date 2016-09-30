------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . T E X T _ I O                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2015, Free Software Foundation, Inc.         --
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
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  Minimal version of Text_IO body for use on Kinetis K64F

with Kinetis_KL25Z;
with Kinetis_KL25Z.UART;
with Kinetis_KL25Z.SIM;
with Kinetis_KL25Z.PORT;
with Interfaces.Bit_Types;
with Microcontroller_Clocks;

package body System.Text_IO is
   use Kinetis_KL25Z;
   use Interfaces.Bit_Types;
   use Microcontroller_Clocks;

   Baud_Rate : constant := 115_200;
   --  Bitrate to use

   ---------
   -- Get --
   ---------

   function Get return Character is
     (Character'Val (UART.Uart0_Registers.D));

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      procedure Set_Baud_Rate;

      procedure Set_Baud_Rate is
         SBR_Field_Value : Positive range 1 .. 16#1FFF#;
         SBR_Field_Encoded : UART.Encoded_Baud_Rate_Type with
           Address => SBR_Field_Value'Address;
         Uart_Clock : Positive;
         Calculated_Baud_Rate : Positive;
         Baud_Diff : Natural;
         Baud_Diff2 : Natural;
         OSR_Value : Natural;
         C4_Value : UART.C4_Type;
         C5_Value : UART.C5_Type;
         BDH_Value : UART.BDH_Type;
      begin
         --
         --  Calculate the first baud rate using the lowest OSR value possible.
         --
         Uart_Clock := Get_Pll_Frequency_Hz / 2;
         SBR_Field_Value := Uart_Clock / (Baud_Rate * 4);
         Calculated_Baud_Rate := Uart_Clock / (4 * SBR_Field_Value);
         if Calculated_Baud_Rate > Baud_Rate then
            Baud_Diff := Calculated_Baud_Rate - Baud_Rate;
         else
            Baud_Diff := Baud_Rate - Calculated_Baud_Rate;
         end if;

         OSR_Value := 4;

         --  Select the best OSR value:
         for I in 5 .. 32 loop
            SBR_Field_Value := Uart_Clock / (Baud_Rate * I);
            Calculated_Baud_Rate := Uart_Clock / (I * SBR_Field_Value);

            if Calculated_Baud_Rate > Baud_Rate then
               Baud_Diff2 := Calculated_Baud_Rate - Baud_Rate;
            else
               Baud_Diff2 := Baud_Rate - Calculated_Baud_Rate;
            end if;

            if Baud_Diff2 <= Baud_Diff then
               Baud_Diff := Baud_Diff2;
               OSR_Value := I;
            end if;
         end loop;

         pragma Assert (Baud_Diff < (Baud_Rate / 100) * 3);

         --
         --  If the OSR is between 4x and 8x then both
         --  edge sampling MUST be turned on.
         --
         if OSR_Value in  4 .. 8 then
            C5_Value := UART.Uart0_Registers.C5;
            C5_Value.BOTHEDGE := 1;
            UART.Uart0_Registers.C5 := C5_Value;
         end if;

         --  Setup OSR value:
         C4_Value := UART.Uart0_Registers.C4;
         C4_Value.OSR := UInt5 (OSR_Value - 1);
         UART.Uart0_Registers.C4 := C4_Value;
         SBR_Field_Value := Uart_Clock / (Baud_Rate * OSR_Value);

         --  Set baud rate in the device:
         BDH_Value := UART.Uart0_Registers.BDH;
         BDH_Value.SBR := SBR_Field_Encoded.High_Part;
         UART.Uart0_Registers.BDH := BDH_Value;
         UART.Uart0_Registers.BDL := SBR_Field_Encoded.Low_Part;
      end Set_Baud_Rate;

      C1_Value : UART.C1_Type;
      C2_Value : UART.C2_Type;
      SOPT2_Value : SIM.SOPT2_Type;
      SCGC4_Value : SIM.SCGC4_Type;
      PCR_Value : PORT.PCR_Type;
   begin
      --
      --  Select the clock source to be used for this UART peripheral:
      --  01 =  MCGFLLCLK clock or MCGPLLCLK/2 clock
      --
      SOPT2_Value := SIM.Registers.SOPT2;
      SOPT2_Value.UART0SRC := 1;
      SIM.Registers.SOPT2 := SOPT2_Value;

      --  Enable UART clock
      SCGC4_Value := SIM.Registers.SCGC4;
      SCGC4_Value.UART0 := 1;
      SIM.Registers.SCGC4 := SCGC4_Value;

      --  Disable UART's transmitter and receiver, while UART is being
      --  configured:
      C2_Value := UART.Uart0_Registers.C2;
      C2_Value.TE := 0;
      C2_Value.RE := 0;
      UART.Uart0_Registers.C2 := C2_Value;

      --  Configure the uart transmission mode: 8-N-1
      --  (8 data bits, no parity bit, 1 stop bit):
      C1_Value := (others => 0);
      UART.Uart0_Registers.C1 := C1_Value;

      --  Configure Tx pin:
      PCR_Value := (MUX => 2, DSE => 1, IRQC => 0, others => 0);
      PORT.PortA_Registers.PCR (1) := PCR_Value;

      --  Configure Rx pin:
      PCR_Value := (MUX => 2, DSE => 1, IRQC => 0, others => 0);
      PORT.PortA_Registers.PCR (2) := PCR_Value;

      Set_Baud_Rate;

      --  Disable generation of Tx/Rx interrupts:
      C2_Value.RIE := 0;
      C2_Value.TIE := 0;
      UART.Uart0_Registers.C2 := C2_Value;

      --  Enable UART's transmitter and receiver:
      C2_Value.TE := 1;
      C2_Value.RE := 1;
      UART.Uart0_Registers.C2 := C2_Value;

      Initialized := True;

   end Initialize;

   -----------------
   -- Is_Tx_Ready --
   -----------------

   function Is_Tx_Ready return Boolean is
     (UART.Uart0_Registers.S1.TDRE = 1);

   -----------------
   -- Is_Rx_Ready --
   -----------------

   function Is_Rx_Ready return Boolean is
     (UART.Uart0_Registers.S1.RDRF = 1);

   ---------
   -- Put --
   ---------

   procedure Put (C : Character) is
   begin
      UART.Uart0_Registers.D := Byte (Character'Pos (C));
   end Put;

   ----------------------------
   -- Use_Cr_Lf_For_New_Line --
   ----------------------------

   function Use_Cr_Lf_For_New_Line return Boolean is (True);

end System.Text_IO;
