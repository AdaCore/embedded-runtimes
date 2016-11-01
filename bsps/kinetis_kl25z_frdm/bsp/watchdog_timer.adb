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
with Kinetis_KL25Z.SIM; use Kinetis_KL25Z;

--  package SIM renames Kinetis_KL25Z.SIM;
package body Watchdog_Timer is
   --
   --  Compile-time flag to enable/disable firing to the watchdog timer
   --
   Watchdog_On : constant Boolean := False;

   procedure Initialize is
      COPC_Value : SIM.COPC_Type;
   begin
      if Watchdog_On then
         --
         --  Select Longest Watchdog Timeout
         --
         --  NOTE: The SIM'S COPC register can only be written once after a
         --  Reset
         --
         COPC_Value := (COPT => 3, others => 0);
      else
         --  Disable the watchdog timer:
         COPC_Value := (COPT => 0, others => 0);
      end if;

      SIM.Registers.COPC := COPC_Value;

   end Initialize;

end Watchdog_Timer;
