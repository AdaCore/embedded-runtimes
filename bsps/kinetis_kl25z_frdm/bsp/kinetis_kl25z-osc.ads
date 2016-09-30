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
--  @summary Register definitions for the Kinetis KL25Z's OSC module
--
package Kinetis_KL25Z.OSC is
   pragma Preelaborate;

   --  CR - OSC Control Register
   type CR_Type is record
      SC16P    : Bit;
      SC8P     : Bit;
      SC4P     : Bit;
      SC2P     : Bit;
      EREFSTEN : Bit;
      ERCLKEN  : Bit;
   end record with
      Size      => Byte'Size,
      Bit_Order => Low_Order_First;

   for CR_Type use record
      SC16P    at 0 range 0 .. 0;
      SC8P     at 0 range 1 .. 1;
      SC4P     at 0 range 2 .. 2;
      SC2P     at 0 range 3 .. 3;
      EREFSTEN at 0 range 5 .. 5;
      ERCLKEN  at 0 range 7 .. 7;
   end record;

   --
   --  OSC Registers
   --
   type Registers_Type is record
      CR : CR_Type;
   end record with
      Volatile;

   Registers : Registers_Type with
      Import, Address => System'To_Address (16#40065000#);
end Kinetis_KL25Z.OSC;
