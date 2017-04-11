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

pragma Restrictions (No_Elaboration_Code);

with Kinetis_K64F.UART;
with Kinetis_K64F.SIM;
with Kinetis_K64F.PORT;
with Interfaces.Bit_Types;
with Microcontroller_Clocks;
with Memory_Protection;
with System.Storage_Elements;

package body System.Text_IO is
   use Kinetis_K64F;
   use Interfaces.Bit_Types;
   use Microcontroller_Clocks;
   use Memory_Protection;
   use System.Storage_Elements;

   Baud_Rate : constant := 115_200;
   --  Bitrate to use

   Initialized_Var : Boolean := False;

   --  Set to True (by Initialize) when the service is initialized. Having this
   --  variable outside allows reinitialization of the service.

   ---------
   -- Get --
   ---------

   function Get return Character is
      Old_MMIO_Region : Data_Region_Type;
      Result : Character;
   begin
      Set_MMIO_Data_Region (UART.Uart0_Registers'Address,
                            UART.Uart0_Registers'Size / Byte'Size,
                            Read_Only,
                            Old_MMIO_Region);

      Result := Character'Val (UART.Uart0_Registers.D);
      Set_MMIO_Data_Region (Old_MMIO_Region);
      return Result;
   end Get;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      C2_Value : UART.C2_Type;
      BDH_Value : UART.BDH_Type;
      Calculated_SBR : Positive range 1 .. 16#1FFF#;
      Encoded_Baud_Rate : UART.Encoded_Baud_Rate_Type with
        Address => Calculated_SBR'Address;
      Old_MMIO_Region : Data_Region_Type;
      Old_Component_Region : Data_Region_Type;
   begin
      Set_MMIO_Data_Region (SIM.Registers'Address,
                            SIM.Registers'Size / Byte'Size,
                            Read_Write,
                            Old_MMIO_Region);

      --  Enable UART clock
      SIM.Registers.SCGC4.UART0 := 1;

      Set_MMIO_Data_Region (UART.Uart0_Registers'Address,
                            UART.Uart0_Registers'Size / Byte'Size,
                            Read_Write);

      --  Disable UART's transmitter and receiver, while UART is being
      --  configured:
      C2_Value := UART.Uart0_Registers.C2;
      C2_Value.TE := 0;
      C2_Value.RE := 0;
      UART.Uart0_Registers.C2 := C2_Value;

      --  Configure the uart transmission mode: 8-N-1
      --  (8 data bits, no parity bit, 1 stop bit):
      UART.Uart0_Registers.C1 := (others => 0);

      --  Configure Tx and RX FIFOs:
      --  - Rx FIFO water mark = 1 (generate interrupt when Rx FIFO is not
      --    empty)
      --  - Enable Tx and Rx FIFOs
      --  - Flush Tx and Rx FIFOs
      UART.Uart0_Registers.RWFIFO := 1;
      UART.Uart0_Registers.PFIFO := (RXFE => 1, TXFE => 1, others => 0);

      UART.Uart0_Registers.CFIFO := (RXFLUSH => 1, TXFLUSH => 1, others => 0);

      Set_MMIO_Data_Region (PORT.PortB_Registers'Address,
                            PORT.PortB_Registers'Size / Byte'Size,
                            Read_Write);

      --  Configure Tx pin:
      PORT.PortB_Registers.PCR (17) := (MUX => 3, DSE => 1, IRQC => 0,
                                        others => 0);

      --  Configure Rx pin:
      PORT.PortB_Registers.PCR (16) := (MUX => 3, DSE => 1, IRQC => 0,
                                        others => 0);

      Set_MMIO_Data_Region (UART.Uart0_Registers'Address,
                            UART.Uart0_Registers'Size / Byte'Size,
                            Read_Write);

      --  Set Baud Rate;
      Calculated_SBR :=
        Positive (System_Clock_Frequency) / (Positive (Baud_Rate) * 16);
      BDH_Value := UART.Uart0_Registers.BDH;
      BDH_Value.SBR := Encoded_Baud_Rate.High_Part;
      UART.Uart0_Registers.BDH := BDH_Value;
      UART.Uart0_Registers.BDL := Encoded_Baud_Rate.Low_Part;

      --  Disable generation of Tx/Rx interrupts:
      C2_Value.RIE := 0;
      C2_Value.TIE := 0;
      UART.Uart0_Registers.C2 := C2_Value;

      --  Enable UART's transmitter and receiver:
      C2_Value.TE := 1;
      C2_Value.RE := 1;
      UART.Uart0_Registers.C2 := C2_Value;

      Set_Component_Data_Region (Initialized'Address,
                                 Initialized'Size / Byte'Size,
                                 Read_Write,
                                 Old_Component_Region);

      Initialized_Var := True;

      Set_Component_Data_Region (Old_Component_Region);
      Set_MMIO_Data_Region (Old_MMIO_Region);
   end Initialize;

   function Initialized return Boolean
   is
      Old_Component_Region : Data_Region_Type;
      Result : Boolean;
   begin
      Set_Component_Data_Region (Initialized_Var'Address,
                                 Initialized_Var'Size / Byte'Size,
                                 Read_Only,
                                 Old_Component_Region);
      Result := Initialized_Var;

      Set_Component_Data_Region (Old_Component_Region);
      return Result;
   end Initialized;

   -----------------
   -- Is_Tx_Ready --
   -----------------

   function Is_Tx_Ready return Boolean is
      Result : Boolean;
      Old_MMIO_Region : Data_Region_Type;
   begin
      Set_MMIO_Data_Region (UART.Uart0_Registers'Address,
                            UART.Uart0_Registers'Size / Byte'Size,
                            Read_Only,
                            Old_MMIO_Region);
      Result := UART.Uart0_Registers.S1.TDRE = 1;
      Set_MMIO_Data_Region (Old_MMIO_Region);
      return Result;
   end Is_Tx_Ready;

   -----------------
   -- Is_Rx_Ready --
   -----------------

   function Is_Rx_Ready return Boolean is
      Result : Boolean;
      Old_MMIO_Region : Data_Region_Type;
   begin
      Set_MMIO_Data_Region (UART.Uart0_Registers'Address,
                            UART.Uart0_Registers'Size / Byte'Size,
                            Read_Only,
                            Old_MMIO_Region);
      Result := UART.Uart0_Registers.S1.RDRF = 1;
      Set_MMIO_Data_Region (Old_MMIO_Region);
      return Result;
   end Is_Rx_Ready;

   ---------
   -- Put --
   ---------

   procedure Put (C : Character) is
      Old_MMIO_Region : Data_Region_Type;
   begin
      Set_MMIO_Data_Region (UART.Uart0_Registers'Address,
                            UART.Uart0_Registers'Size / Byte'Size,
                            Read_Write,
                            Old_MMIO_Region);

      UART.Uart0_Registers.D := Byte (Character'Pos (C));

      Set_MMIO_Data_Region (Old_MMIO_Region);
   end Put;

   ----------------------------
   -- Use_Cr_Lf_For_New_Line --
   ----------------------------

   function Use_Cr_Lf_For_New_Line return Boolean is (True);

end System.Text_IO;
