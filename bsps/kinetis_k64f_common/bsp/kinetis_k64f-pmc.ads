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
--  @summary Register definitions for the Kinetis K64F's PMC hardware block
--
package Kinetis_K64F.PMC is
   pragma Preelaborate;

   --  LVDSC1 - Low Voltage Detect Status And Control 1 register
   type LVDSC1_Type is record
      LVDV : Two_Bits;
      LVDRE : Bit;
      LVDIE : Bit;
      LVDACK : Bit;
      LVDF : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for LVDSC1_Type use
      record
         LVDV at 0 range 0 .. 1;
         LVDRE at 0 range 4 .. 4;
         LVDIE at 0 range 5 .. 5;
         LVDACK at 0 range 6 .. 6;
         LVDF at 0 range 7 .. 7;
      end record;

   --  LVDSC2 - Low Voltage Detect Status And Control 2 register
   type LVDSC2_Type is record
      LVWV : Two_Bits;
      LVWIE : Bit;
      LVWACK : Bit;
      LVWF : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for LVDSC2_Type use
      record
         LVWV at 0 range 0 .. 1;
         LVWIE at 0 range 5 .. 5;
         LVWACK at 0 range 6 .. 6;
         LVWF at 0 range 7 .. 7;
      end record;

   --  REGSC - Regulator Status And Control register
   type REGSC_Type is record
      BGBE : Bit;
      REGONS : Bit;
      ACKISO : Bit;
      BGEN : Bit;
   end record with Size => Byte'Size, Bit_Order => Low_Order_First;

   for REGSC_Type use
      record
         BGBE at 0 range 0 .. 0;
         REGONS at 0 range 2 .. 2;
         ACKISO at 0 range 3 .. 3;
         BGEN at 0 range 4 .. 4;
      end record;

   --
   --  PMC Registers
   --
   type Registers_Type is record
      LVDSC1 : LVDSC1_Type;
      LVDSC2 : LVDSC2_Type;
      REGSC : REGSC_Type;
   end record with Volatile;

   Registers : Registers_Type with
     Import, Address => System'To_Address (16#4007D000#);
end Kinetis_K64F.PMC;
