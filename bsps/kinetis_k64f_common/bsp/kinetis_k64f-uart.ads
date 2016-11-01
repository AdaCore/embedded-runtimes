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
--  @summary Register definitions for the Kinetis K64F's UART hardware block
--
package Kinetis_K64F.UART is
   pragma Preelaborate;

   type Encoded_Baud_Rate_Type is record
      Low_Part : Byte;
      High_Part : Five_Bits;
   end record with Size => Half_Word'Size, Bit_Order => Low_Order_First;

   for Encoded_Baud_Rate_Type use
      record
         Low_Part at 0 range 0 .. 7;
         High_Part at 0 range 8 .. 12;
      end record;

   --  BDH - UART Baud Rate Register: High
   type BDH_Type is record
      SBR : Five_Bits;
      SBNS : Bit;
      RXEDGIE : Bit;
      LBKDIE : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for BDH_Type use
      record
         SBR at 0 range 0 .. 4;
         SBNS at 0 range 5 .. 5;
         RXEDGIE at 0 range 6 .. 6;
         LBKDIE at 0 range 7 .. 7;
      end record;

   --  C1 - UART Control Register 1
   type C1_Type is record
      PT : Bit;
      PE : Bit;
      ILT : Bit;
      WAKE : Bit;
      M : Bit;
      RSRC : Bit;
      UARTSWAI : Bit;
      LOOPS : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for C1_Type use
      record
         PT at 0 range 0 .. 0;
         PE at 0 range 1 .. 1;
         ILT at 0 range 2 .. 2;
         WAKE at 0 range 3 .. 3;
         M at 0 range 4 .. 4;
         RSRC at 0 range 5 .. 5;
         UARTSWAI at 0 range 6 .. 6;
         LOOPS at 0 range 7 .. 7;
      end record;

   --  C2 - UART Control Register 2
   type C2_Type is record
      SBK : Bit;
      RWU : Bit;
      RE : Bit;
      TE : Bit;
      ILIE : Bit;
      RIE : Bit;
      TCIE : Bit;
      TIE : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for C2_Type use
      record
         SBK at 0 range 0 .. 0;
         RWU at 0 range 1 .. 1;
         RE at 0 range 2 .. 2;
         TE at 0 range 3 .. 3;
         ILIE at 0 range 4 .. 4;
         RIE at 0 range 5 .. 5;
         TCIE at 0 range 6 .. 6;
         TIE at 0 range 7 .. 7;
      end record;

   --  S1 - UART Status Register 1
   type S1_Type is record
      PF : Bit;
      FE : Bit;
      NF : Bit;
      S1_OR : Bit;
      IDLE : Bit;
      RDRF : Bit;
      TC : Bit;
      TDRE : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for S1_Type use
      record
         PF at 0 range 0 .. 0;
         FE at 0 range 1 .. 1;
         NF at 0 range 2 .. 2;
         S1_OR at 0 range 3 .. 3;
         IDLE at 0 range 4 .. 4;
         RDRF at 0 range 5 .. 5;
         TC at 0 range 6 .. 6;
         TDRE at 0 range 7 .. 7;
      end record;

   --  PFIFO - UART FIFO Parameters
   type PFIFO_Type is record
      RXFIFOSIZE : Three_Bits;
      RXFE : Bit;
      TXFIFOSIZE : Three_Bits;
      TXFE : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for PFIFO_Type use
      record
         RXFIFOSIZE at 0 range 0 .. 2;
         RXFE at 0 range 3 .. 3;
         TXFIFOSIZE at 0 range 4 .. 6;
         TXFE at 0 range 7 .. 7;
      end record;

   --   CFIFO - UART FIFO Control Register
   type CFIFO_Type is record
      RXUFE : Bit;
      TXOFE : Bit;
      RXOFE : Bit;
      RXFLUSH : Bit;
      TXFLUSH : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for CFIFO_Type use
      record
         RXUFE at 0 range 0 .. 0;
         TXOFE at 0 range 1 .. 1;
         RXOFE at 0 range 2 .. 2;
         RXFLUSH at 0 range 6 .. 6;
         TXFLUSH at 0 range 7 .. 7;
      end record;

   type Registers_Type is record
      BDH :  BDH_Type;
      BDL :  Byte;
      C1 :  C1_Type;
      C2 :  C2_Type;
      S1 :  S1_Type;
      S2 :  Byte;
      C3 :  Byte;
      D :  Byte;
      MA1 :  Byte;
      MA2 :  Byte;
      C4 :  Byte;
      C5 :  Byte;
      ED :  Byte;
      MODEM :  Byte;
      IR :  Byte;
      Reserved_0 :  Byte;
      PFIFO :  PFIFO_Type;
      CFIFO :  CFIFO_Type;
      SFIFO :  Byte;
      TWFIFO :  Byte;
      TCFIFO :  Byte;
      RWFIFO :  Byte;
      RCFIFO :  Byte;
      Reserved_1 :  Byte;
      C7816 :  Byte;
      IE7816 :  Byte;
      IS7816 :  Byte;
      WP7816T : Byte;
      WN7816 :  Byte;
      WF7816 :  Byte;
      ET7816 :  Byte;
      TL7816 :  Byte;
   end record with Volatile;

   Uart0_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#4006A000#);

   Uart1_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#4006B000#);

   Uart2_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#4006C000#);

   Uart3_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#4006D000#);

   Uart4_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400EA000#);

   Uart5_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400EB000#);

end Kinetis_K64F.UART;
