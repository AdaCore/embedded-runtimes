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
--  @summary Register definitions for the Kinetis K64F's RCM hardware block
--
package Kinetis_K64F.RCM is
   pragma Preelaborate;

   --  SRS0 - System Reset Status Register 0
   type SRS0_Type is record
      WAKEUP : Bit;
      LVD  : Bit;
      LOC  : Bit;
      LOL : Bit;
      WDOG : Bit;
      PIN : Bit;
      POR : Bit;
   end record with
     Size      => Byte'Size,
     Bit_Order => Low_Order_First;

   for SRS0_Type use record
      WAKEUP at 0 range 0 .. 0;
      LVD at 0 range 1 .. 1;
      LOC at 0 range 2 .. 2;
      LOL at 0 range 3 .. 3;
      WDOG at 0 range 5 .. 5;
      PIN at 0 range 6 .. 6;
      POR at 0 range 7 .. 7;
   end record;

   --  SRS1 - System Reset Status Register 1
   type SRS1_Type is record
      JTAG : Bit;
      LOCKUP : Bit;
      SW : Bit;
      MDM_AP : Bit;
      EZPT : Bit;
      SACKERR : Bit;
   end record with
     Size      => Byte'Size,
     Bit_Order => Low_Order_First;

   for SRS1_Type use record
      JTAG at 0 range 0 .. 0;
      LOCKUP at 0 range 1 .. 1;
      SW at 0 range 2 .. 2;
      MDM_AP at 0 range 3 .. 3;
      EZPT at 0 range 4 .. 4;
      SACKERR at 0 range 5 .. 5;
   end record;

   --
   --  RCM Registers
   --
   type Registers_Type is record
      SRS0 : SRS0_Type;
      SRS1 : SRS1_Type;
      Reserved1 : Bytes_Array (1 .. 2);
      RPFC : Byte;
      RPFW : Byte;
      Reserved2 : Byte;
      MR : Byte;
   end record with
     Volatile, Size => 16#8# * Byte'Size;

   Registers : Registers_Type with
     Import, Address => System'To_Address (16#4007F000#);
end Kinetis_K64F.RCM;
