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
--  @summary Register definitions for the Kinetis K64F's SIM hardware block
--
package Kinetis_K64F.SIM is
   pragma Preelaborate;

   --  SOPT1 - System Options Register 1
   type SOPT1_Type is record
      RAMSIZE : Four_Bits;
      OSC32KSEL : Two_Bits;
      USBVSTBY : Bit;
      USBSSTBY : Bit;
      USBREGEN : Bit;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for SOPT1_Type use
      record
         RAMSIZE at 0 range 12 .. 15;
         OSC32KSEL at 0 range 18 .. 19;
         USBVSTBY at 0 range 29 .. 29;
         USBSSTBY at 0 range 30 .. 30;
         USBREGEN at 0 range 31 .. 31;
      end record;

   --  SOPT2 - System Options Register 2
   type SOPT2_Type is record
      RTCCLKOUTSEL : Bit;
      CLKOUTSEL : Three_Bits;
      FBSL : Two_Bits;
      PTD7PAD : Bit;
      TRACECLKSEL : Bit;
      PLLFLLSEL : Two_Bits;
      USBSRC : Bit;
      RMIISRC : Bit;
      TIMESRC : Two_Bits;
      SDHCSRC : Two_Bits;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for SOPT2_Type use
      record
         RTCCLKOUTSEL at 0 range 4 .. 4;
         CLKOUTSEL at 0 range 5 .. 7;
         FBSL at 0 range 8 .. 9;
         PTD7PAD at 0 range 11 .. 11;
         TRACECLKSEL at 0 range 12 .. 12;
         PLLFLLSEL at 0 range 16 .. 17;
         USBSRC at 0 range 18 .. 18;
         RMIISRC at 0 range 19 .. 19;
         TIMESRC at 0 range 20 .. 21;
         SDHCSRC at 0 range 28 .. 29;
      end record;

   --  SCGC1 - System Clock Gating Control Register 1
   type SCGC1_Type is record
      I2C2 : Bit;
      UART4 : Bit;
      UART5 : Bit;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for SCGC1_Type use
      record
         I2C2 at 0 range 6 .. 6;
         UART4 at 0 range 10 .. 10;
         UART5 at 0 range 11 .. 11;
      end record;

   --  SCGC4 - System Clock Gating Control Register 4
   type SCGC4_Type is record
      EWM : Bit;
      CMT : Bit;
      I2C0 : Bit;
      I2C1 : Bit;
      UART0 : Bit;
      UART1 : Bit;
      UART2 : Bit;
      UART3 : Bit;
      USBOTG : Bit;
      CMP : Bit;
      VREF : Bit;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for SCGC4_Type use
      record
         EWM at 0 range 1 .. 1;
         CMT at 0 range 2 .. 2;
         I2C0 at 0 range 6 .. 6;
         I2C1 at 0 range 7 .. 7;
         UART0 at 0 range 10 .. 10;
         UART1 at 0 range 11 .. 11;
         UART2 at 0 range 12 .. 12;
         UART3 at 0 range 13 .. 13;
         USBOTG at 0 range 18 .. 18;
         CMP at 0 range 19 .. 19;
         VREF at 0 range 20 .. 20;
      end record;

   --  SCGC5 - System Clock Gating Control Register 5
   type SCGC5_Type is record
      LPTMR : Bit;
      PORTA : Bit;
      PORTB : Bit;
      PORTC : Bit;
      PORTD : Bit;
      PORTE : Bit;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for SCGC5_Type use
      record
         LPTMR at 0 range 0 .. 0;
         PORTA at 0 range 9 .. 9;
         PORTB at 0 range 10 .. 10;
         PORTC at 0 range 11 .. 11;
         PORTD at 0 range 12 .. 12;
         PORTE at 0 range 13 .. 13;
      end record;

   --  CLKDIV1 - System Clock Divider Register 1
   type CLKDIV1_Type is record
      OUTDIV4 : Four_Bits;
      OUTDIV3 : Four_Bits;
      OUTDIV2 : Four_Bits;
      OUTDIV1 : Four_Bits;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for CLKDIV1_Type use
      record
         OUTDIV4 at 0 range 16 .. 19;
         OUTDIV3 at 0 range 20 .. 23;
         OUTDIV2 at 0 range 24 .. 27;
         OUTDIV1 at 0 range 28 .. 31;
      end record;

   --  CLKDIV2 - System Clock Divider Register 2
   type CLKDIV2_Type is record
      USBFRAC : Bit;
      USBDIV : Three_Bits;
   end record with Size => Word'Size, Bit_Order => Low_Order_First;

   for CLKDIV2_Type use
      record
         USBFRAC at 0 range 0 .. 0;
         USBDIV at 0 range 1 .. 3;
      end record;

   --
   --  SIM registers
   --
   type Registers_Type is record
      SOPT1 : SOPT1_Type;
      SOPT1CFG : Word;
      Reserved_0 : Bytes_Array (1 .. 4092);
      SOPT2 : SOPT2_Type;
      Reserved_1 : Bytes_Array (1 .. 4);
      SOPT4 : Word;
      SOPT5 : Word;
      Reserved_2 : Bytes_Array (1 .. 4);
      SOPT7 : Word;
      Reserved_3 : Bytes_Array (1 .. 8);
      SDID : Word;
      SCGC1 : SCGC1_Type;
      SCGC2 : Word;
      SCGC3 : Word;
      SCGC4 : SCGC4_Type;
      SCGC5 : SCGC5_Type;
      SCGC6 : Word;
      SCGC7 : Word;
      CLKDIV1 : CLKDIV1_Type;
      CLKDIV2 : CLKDIV2_Type;
      FCFG1 : Word;
      FCFG2 : Word;
      UIDH : Word;
      UIDMH : Word;
      UIDML : Word;
      UIDL : Word;
   end record with Volatile;

   Registers : Registers_Type with
     Import, Address => System'To_Address (16#40047000#);
end Kinetis_K64F.SIM;
