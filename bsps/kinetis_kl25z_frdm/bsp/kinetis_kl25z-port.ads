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
--  @summary Register definitions for the Kinetis KL25Z's PORT module
--
package Kinetis_KL25Z.PORT is
   pragma Preelaborate;

   --  PCR - Pin Control Register
   type PCR_Type is record
      PS   : Bit;
      PE   : Bit;
      SRE  : Bit;
      PFE  : Bit;
      DSE  : Bit;
      MUX  : UInt3;
      IRQC : UInt4;
      ISF  : Bit;
   end record with
      Size      => Word'Size,
      Bit_Order => Low_Order_First;

   for PCR_Type use record
      PS   at 0 range  0 ..  0;
      PE   at 0 range  1 ..  1;
      SRE  at 0 range  2 ..  2;
      PFE  at 0 range  4 ..  4;
      DSE  at 0 range  6 ..  6;
      MUX  at 0 range  8 .. 10;
      IRQC at 0 range 16 .. 19;
      ISF  at 0 range 24 .. 24;
   end record;

   Num_Pins_Per_Port : constant Natural := Word'Size;

   type Pin_Index_Type is range 0 .. Num_Pins_Per_Port - 1;

   type Pin_Array_Type is array (Pin_Index_Type) of Bit
     with Component_Size => 1, Size => Word'Size;

   type PCR_Array is array (Pin_Index_Type) of PCR_Type;

   --
   --  PORT registers
   --
   type Registers_Type is record
      PCR        : PCR_Array;
      GPCLR      : Word;
      GPCHR      : Word;
      Reserved_0 : Bytes_Array (1 .. 24);
      ISFR       : Pin_Array_Type;
   end record with
      Volatile,
      Size => 16#A4# * Byte'Size;

   PortA_Registers : aliased Registers_Type with
      Import, Address => System'To_Address (16#40049000#);

   PortB_Registers : aliased Registers_Type with
      Import, Address => System'To_Address (16#4004A000#);

   PortC_Registers : aliased Registers_Type with
      Import, Address => System'To_Address (16#4004B000#);

   PortD_Registers : aliased Registers_Type with
      Import, Address => System'To_Address (16#4004C000#);

   PortE_Registers : aliased Registers_Type with
      Import, Address => System'To_Address (16#4004D000#);

end Kinetis_KL25Z.PORT;
