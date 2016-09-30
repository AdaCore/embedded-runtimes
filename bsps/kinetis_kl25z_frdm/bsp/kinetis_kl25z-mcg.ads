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
--  @summary Register definitions for the Kinetis KL25Z's MCG module
--
package Kinetis_KL25Z.MCG is
   pragma Preelaborate;

   --  C1 - MCG Control 1 Register
   type C1_Type is record
      IREFSTEN : Bit;
      IRCLKEN  : Bit;
      IREFS    : Bit;
      FRDIV    : UInt3;
      CLKS     : UInt2;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for C1_Type use record
      IREFSTEN at 0 range 0 .. 0;
      IRCLKEN  at 0 range 1 .. 1;
      IREFS    at 0 range 2 .. 2;
      FRDIV    at 0 range 3 .. 5;
      CLKS     at 0 range 6 .. 7;
   end record;

   --  C2 - MCG Control 2 Register
   type C2_Type is record
      IRCS   : Bit;
      LP     : Bit;
      EREFS0 : Bit;
      HGO0   : Bit;
      RANGE0 : UInt2;
      LOCRE0 : Bit;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for C2_Type use record
      IRCS   at 0 range 0 .. 0;
      LP     at 0 range 1 .. 1;
      EREFS0 at 0 range 2 .. 2;
      HGO0   at 0 range 3 .. 3;
      RANGE0 at 0 range 4 .. 5;
      LOCRE0 at 0 range 7 .. 7;
   end record;

   --  C4 - MCG Control 4 Register
   type C4_Type is record
      SCFTRIM  : Bit;
      FCTRIM   : UInt4;
      DRST_DRS : UInt2;
      DMX32    : Bit;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for C4_Type use record
      SCFTRIM  at 0 range 0 .. 0;
      FCTRIM   at 0 range 1 .. 4;
      DRST_DRS at 0 range 5 .. 6;
      DMX32    at 0 range 7 .. 7;
   end record;

   --  C5 - MCG Control 5 Register
   type C5_Type is record
      PRDIV0    : UInt5;
      PLLSTEN0  : Bit;
      PLLCLKEN0 : Bit;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for C5_Type use record
      PRDIV0    at 0 range 0 .. 4;
      PLLSTEN0  at 0 range 5 .. 5;
      PLLCLKEN0 at 0 range 6 .. 6;
   end record;

   --  C6 - MCG Control 6 Register
   type C6_Type is record
      VDIV0  : UInt5;
      CME0   : Bit;
      PLLS   : Bit;
      LOLIE0 : Bit;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for C6_Type use record
      VDIV0  at 0 range 0 .. 4;
      CME0   at 0 range 5 .. 5;
      PLLS   at 0 range 6 .. 6;
      LOLIE0 at 0 range 7 .. 7;
   end record;

   --  C7 - MCG Control 7 Register
   type C7_Type is record
      OSCSEL   : UInt2;
      Reserved : UInt6;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for C7_Type use record
      OSCSEL   at 0 range 0 .. 1;
      Reserved at 0 range 2 .. 7;
   end record;

   --  S - MCG Status Register
   type S_Type is record
      IRCST    : Bit;
      OSCINIT0 : Bit;
      CLKST    : UInt2;
      IREFST   : Bit;
      PLLST    : Bit;
      LOCK0    : Bit;
      LOLS0    : Bit;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for S_Type use record
      IRCST    at 0 range 0 .. 0;
      OSCINIT0 at 0 range 1 .. 1;
      CLKST    at 0 range 2 .. 3;
      IREFST   at 0 range 4 .. 4;
      PLLST    at 0 range 5 .. 5;
      LOCK0    at 0 range 6 .. 6;
      LOLS0    at 0 range 7 .. 7;
   end record;

   --
   --  MCG Register
   --
   type Registers_Type is record
      C1         : C1_Type;
      C2         : C2_Type;
      C3         : Byte;
      C4         : C4_Type;
      C5         : C5_Type;
      C6         : C6_Type;
      S          : S_Type;
      Reserved_0 : Byte;
      SC         : Byte;
      Reserved_1 : Byte;
      ATCVH      : Byte;
      ATCVL      : Byte;
      C7         : C7_Type;
      C8         : Byte;
      C9         : Byte;
      C10        : Byte;
   end record with
      Volatile;

   Registers : Registers_Type with
      Import, Address => System'To_Address (16#40064000#);

end Kinetis_KL25Z.MCG;
