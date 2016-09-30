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

with Kinetis_K64F.PORT;

--
--  @summary Register definitions for the Kinetis K64F's GPIO hardware block
--
package Kinetis_K64F.GPIO is
   pragma Preelaborate;

   --
   --  GPIO registers
   --
   type Registers_Type is record
      PDOR : PORT.Pin_Array_Type;
      PSOR : PORT.Pin_Array_Type;
      PCOR : PORT.Pin_Array_Type;
      PTOR : PORT.Pin_Array_Type;
      PDIR : PORT.Pin_Array_Type;
      PDDR : PORT.Pin_Array_Type;
   end record with Volatile, Size => 16#18# * Byte'Size;

   PortA_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400FF000#);

   PortB_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400FF040#);

   PortC_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400FF080#);

   PortD_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400FF0C0#);

   PortE_Registers : aliased Registers_Type with
     Import, Address => System'To_Address (16#400FF100#);
end Kinetis_K64F.GPIO;
