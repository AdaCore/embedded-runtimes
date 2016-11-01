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
with Kinetis_K64F.WDOG; use Kinetis_K64F;

package body Watchdog_Timer is
   --
   --  Compile-time flag to enable/disable firing to the watchdog timer
   --
   Watchdog_On : constant Boolean := False;

   --  Watchdog timeout value in watchdog clock cycles:
   Watchdog_Timeout : constant Half_Word := 16#2ff#; -- ~ 5s

   procedure Initialize is
      STCTRLH_Value : WDOG.STCTRLH_Type;
   begin
      --
      --  First, we need to unlock the Watchdog, and to do so, two
      --  writes must be done on the 'WDOG->UNLOCK' register without using
      --  I/O accessors, due to strict timing requirements.
      --  We also assume this function is called with interrupts disabled to
      --  ensure the sequence of the two writes is atomic. We cannot use
      --  disable_cpu_interrupts() here, as this function is called very early
      --  in the reset handler, before regular C global variables are
      --  initialized.
      --
      WDOG.Registers.UNLOCK := 16#C520#; --  Key 1
      WDOG.Registers.UNLOCK := 16#D928#; --  Key 2

      if Watchdog_On then
         --
         --  Select LPO as clock source for the watchdog:
         --
         --  NOTE: Upon reset, the watchdog is enabled by default,
         --  so we just need to set its clock source.
         --
         --  Reset value of WDOG->STCTRLH:
         --  ?=0,DISTESTWDOG=0,BYTESEL=0,TESTSEL=0,TESTWDOG=0,?=0,?=1,
         --  WAITEN=1,STOPEN=1,DBGEN=0,ALLOWUPDATE=1,WINEN=0,IRQRSTEN=0,
         --  CLKSRC=1,WDOGEN=1
         --
         STCTRLH_Value := WDOG.Registers.STCTRLH;
         STCTRLH_Value.CLKSRC := 0;
         WDOG.Registers.STCTRLH := STCTRLH_Value;

         --  Set watchdog timeout value:
         WDOG.Registers.TOVALH := 0;
         WDOG.Registers.TOVALL := Watchdog_Timeout;
      else
         --
         --  Explicitly disable the watchdog because it will cause a reset:
         --
         --  NOTE: Upon reset, the watchdog is enabled by default.
         --  Reset value of WDOG->STCTRLH:
         --  ?=0,DISTESTWDOG=0,BYTESEL=0,TESTSEL=0,TESTWDOG=0,?=0,?=1,
         --  WAITEN=1,STOPEN=1,DBGEN=0,ALLOWUPDATE=1,WINEN=0,IRQRSTEN=0,
         --  CLKSRC=1, WDOGEN=1
         --
         STCTRLH_Value := WDOG.Registers.STCTRLH;
         STCTRLH_Value.CLKSRC := 0;
         STCTRLH_Value.WDOGEN := 0;
         WDOG.Registers.STCTRLH := STCTRLH_Value;
      end if;

   end Initialize;

end Watchdog_Timer;
