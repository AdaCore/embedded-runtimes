--
--  Copyright (c) 2016, German Rivera
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--
--  * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
--  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
--  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
--  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
--  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
--  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--

pragma Restrictions (No_Elaboration_Code);

--
--  @summary Register definitions for the Kinetis KL25Z's SIM mmodule
--
package Kinetis_KL25Z.SIM is
   pragma Preelaborate;

   --  SOPT1 - System Options Register 1
   type SOPT1_Type is record
      OSC32KSEL : UInt2;
      USBVSTBY  : Bit;
      USBSSTBY  : Bit;
      USBREGEN  : Bit;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for SOPT1_Type use record
      OSC32KSEL at 0 range 18 .. 19;
      USBVSTBY  at 0 range 29 .. 29;
      USBSSTBY  at 0 range 30 .. 30;
      USBREGEN  at 0 range 31 .. 31;
   end record;

   --  SOPT2 - System Options Register 2
   type SOPT2_Type is record
      RTCCLKOUTSEL : Bit;
      CLKOUTSEL    : UInt3;
      PLLFLLSEL    : Bit;
      USBSRC       : Bit;
      TPMSRC       : UInt2;
      UART0SRC     : UInt2;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for SOPT2_Type use record
      RTCCLKOUTSEL at 0 range  4 ..  4;
      CLKOUTSEL    at 0 range  5 ..  7;
      PLLFLLSEL    at 0 range 16 .. 16;
      USBSRC       at 0 range 18 .. 18;
      TPMSRC       at 0 range 24 .. 25;
      UART0SRC     at 0 range 26 .. 27;
   end record;

   --  SCGC4 - System Clock Gating Control Register 4
   type SCGC4_Type is record
      EWM    : Bit;
      CMT    : Bit;
      I2C0   : Bit;
      I2C1   : Bit;
      UART0  : Bit;
      UART1  : Bit;
      UART2  : Bit;
      UART3  : Bit;
      USBOTG : Bit;
      CMP    : Bit;
      VREF   : Bit;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for SCGC4_Type use record
      EWM    at 0 range  1 ..  1;
      CMT    at 0 range  2 ..  2;
      I2C0   at 0 range  6 ..  6;
      I2C1   at 0 range  7 ..  7;
      UART0  at 0 range 10 .. 10;
      UART1  at 0 range 11 .. 11;
      UART2  at 0 range 12 .. 12;
      UART3  at 0 range 13 .. 13;
      USBOTG at 0 range 18 .. 18;
      CMP    at 0 range 19 .. 19;
      VREF   at 0 range 20 .. 20;
   end record;

   --  SCGC5 - System Clock Gating Control Register 5
   type SCGC5_Type is record
      LPTMR : Bit;
      PORTA : Bit;
      PORTB : Bit;
      PORTC : Bit;
      PORTD : Bit;
      PORTE : Bit;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for SCGC5_Type use record
      LPTMR at 0 range  0 ..  0;
      PORTA at 0 range  9 ..  9;
      PORTB at 0 range 10 .. 10;
      PORTC at 0 range 11 .. 11;
      PORTD at 0 range 12 .. 12;
      PORTE at 0 range 13 .. 13;
   end record;

   --  CLKDIV1 - System Clock Divider Register 1
   type CLKDIV1_Type is record
      OUTDIV4 : UInt3;
      OUTDIV1 : UInt4;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for CLKDIV1_Type use record
      OUTDIV4 at 0 range 16 .. 18;
      OUTDIV1 at 0 range 28 .. 31;
   end record;

   --  COP Control Register
   type COPC_Type is record
      COPW    : Bit;
      COPCLKS : Bit;
      COPT    : UInt2;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for COPC_Type use record
      COPW    at 0 range 0 .. 0;
      COPCLKS at 0 range 1 .. 1;
      COPT    at 0 range 2 .. 3;
   end record;

   --
   --  SIM registers
   --
   type Registers_Type is record
      SOPT1      : SOPT1_Type;
      SOPT1CFG   : Word;
      Reserved_0 : Bytes_Array (1 .. 4092);
      SOPT2      : SOPT2_Type;
      Reserved_1 : Bytes_Array (1 .. 4);
      SOPT4      : Word;
      SOPT5      : Word;
      Reserved_2 : Bytes_Array (1 .. 4);
      SOPT7      : Word;
      Reserved_3 : Bytes_Array (1 .. 8);
      SDID       : Word;
      Reserved_4 : Bytes_Array (1 .. 12);
      SCGC4      : SCGC4_Type;
      SCGC5      : SCGC5_Type;
      SCGC6      : Word;
      SCGC7      : Word;
      CLKDIV1    : CLKDIV1_Type;
      Reserved_5 : Bytes_Array (1 .. 4);
      FCFG1      : Word;
      FCFG2      : Word;
      Reserved_6 : Bytes_Array (1 .. 4);
      UIDMH      : Word;
      UIDML      : Word;
      UIDL       : Word;
      Reserved_7 : Bytes_Array (1 .. 156);
      COPC       : COPC_Type;
      SRVCOP     : Word;
   end record with
      Volatile,
      Size => 16#1108# * Byte'Size;

   Registers : Registers_Type with
      Import, Address => System'To_Address (16#40047000#);

end Kinetis_KL25Z.SIM;
