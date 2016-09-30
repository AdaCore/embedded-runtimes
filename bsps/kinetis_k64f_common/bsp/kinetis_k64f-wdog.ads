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
--  @summary Register definitions for the Kinetis K64F's WDOG hardware block
--
package Kinetis_K64F.WDOG is
   pragma Preelaborate;

   --   STCTRLH - Watchdog Status and Control Register High
   type STCTRLH_Type is record
      WDOGEN : Bit;
      CLKSRC : Bit;
      IRQRSTEN : Bit;
      WINEN : Bit;
      ALLOWUPDATE : Bit;
      DBGEN : Bit;
      STOPEN : Bit;
      WAITEN : Bit;
      TESTWDOG : Bit;
      TESTSEL : Bit;
      BYTESEL : Two_Bits;
      DISTESTWDOG : Bit;
   end record with Size => Half_Word'Size, Bit_Order => Low_Order_First;

   for STCTRLH_Type use
      record
         WDOGEN at 0 range 0 .. 0;
         CLKSRC at 0 range 1 .. 1;
         IRQRSTEN at 0 range 2 .. 2;
         WINEN at 0 range 3 .. 3;
         ALLOWUPDATE at 0 range 4 .. 4;
         DBGEN at 0 range 5 .. 5;
         STOPEN at 0 range 6 .. 6;
         WAITEN at 0 range 7 .. 7;
         TESTWDOG at 0 range 10 .. 10;
         TESTSEL at 0 range 11 .. 11;
         BYTESEL at 0 range 12 .. 13;
         DISTESTWDOG at 0 range 14 .. 14;
      end record;

   type Registers_Type is record
      STCTRLH :  STCTRLH_Type;  --  Status and Control Register High
      STCTRLL :  Half_Word;     --  Status and Control Register Low
      TOVALH :  Half_Word;      --  Time-out Value Register High
      TOVALL :  Half_Word;      --  Time-out Value Register Low
      WINH :  Half_Word;        --  Window Register High
      WINL :  Half_Word;        --  Window Register Low
      REFRESH :  Half_Word;     --  Refresh register
      UNLOCK :  Half_Word;      --  Unlock register
      TMROUTH :  Half_Word;     --  Timer Output Register High
      TMROUTL :  Half_Word;     --  Timer Output Register Low
      RSTCNT :  Half_Word;      --  Reset Count register
      PRESC :  Half_Word;       --  Prescaler register
   end record with Volatile;

   Registers : Registers_Type with
     Import, Address => System'To_Address (16#40052000#);

end Kinetis_K64F.WDOG;
