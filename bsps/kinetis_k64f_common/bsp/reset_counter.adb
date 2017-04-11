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

with Interfaces.Bit_Types;
with Memory_Protection;
with System.Storage_Elements;

package body Reset_Counter is
   use Interfaces.Bit_Types;
   use Memory_Protection;
   use System.Storage_Elements;

   --
   --  CPU reset counter object type
   --
   --  @field Count Number of CPU resets since last power-cycle
   --  @filed Checksum Last checksum calculated for this object excluding
   --         this field
   --
   --  NOTE: Since SRAM will contain garbage after power-cycling the
   --  microcontroller, we need to use a checksum to be able to
   --  differentiate garbage from valid data from a previous reset.
   --
   type Cpu_Reset_Counter_Type is record
      Count : Unsigned_32;
      Checksum : Unsigned_32;
   end record with Alignment => Memory_Protection.MPU_Region_Alignment;

   Cpu_Reset_Counter : Cpu_Reset_Counter_Type
     with Linker_Section => ".cpu_reset_counter";

   -- ** --

   function Mem_Checksum (Start_Addr : Address; Size : Unsigned_32)
                          return Unsigned_32 is
   --
   --  Computes the CRC-32 checksum for a given block of memory
   --  @param Start_Addr: start address of the memory block
   --  @param Size: size in bytes
   --
      Crc_32_Polynomial : constant Unsigned_32 := 16#04c11db7#;
      Bytes : array (1 .. Size) of Byte with Address => Start_Addr;
      Crc : Unsigned_32 := 16#ffffffff#;
      C : Byte;
   begin
      for Elem of Bytes loop
         C := Elem;
         for I in 1 .. 8 loop
            if ((Unsigned_32 (C) xor Crc) and 1) /= 0 then
               Crc := Shift_Right (Crc, 1);
               C := Shift_Right (C, 1);
               Crc := Crc xor Crc_32_Polynomial;
            else
               Crc := Shift_Right (Crc, 1);
               C := Shift_Right (C, 1);
            end if;
         end loop;
      end loop;

      return Crc;
   end Mem_Checksum;

   -- ** --

   function Valid return Boolean is
   --
   --  Computes the checksum for the CPU reset counter. If the checksum does
   --  not match, g_cpu_reset_counter contains garbage.
   --
   --  NOTE: SRAM contains garbage after power-cycling the microcontroller.
   --  However, it keeps its values across resets.
   --
   --  @return true, if CPU reset counter was valid (checksum matched)
   --  @return false, if CPU reset count was invalid (checksum did not match)
   --
      Crc : Unsigned_32;
   begin
      Crc := Mem_Checksum (Cpu_Reset_Counter.Count'Address,
                           Cpu_Reset_Counter.Count'Size / Byte'Size);

      return Crc = Cpu_Reset_Counter.Checksum;
   end Valid;

   -- ** --

   procedure Update is
   begin
      --
      --  Note: This subprogram gets invoked at startup time before
      --  the memory protection is intialized. So, we can't call
      --  Set_Component_Data_Region here
      --
      if Valid then
         Cpu_Reset_Counter.Count := Cpu_Reset_Counter.Count + 1;
      else
         Cpu_Reset_Counter.Count := 0;
      end if;

      Cpu_Reset_Counter.Checksum :=
        Mem_Checksum (Cpu_Reset_Counter.Count'Address,
                      Cpu_Reset_Counter.Count'Size / Byte'Size);
   end Update;

   -- ** --

   function Get return Unsigned_32 is
      Old_Component_Region : Data_Region_Type;
      Result : Unsigned_32;
   begin
      Set_Component_Data_Region (Cpu_Reset_Counter'Address,
                                 Cpu_Reset_Counter'Size / Byte'Size,
                                 Read_Only,
                                 Old_Component_Region);

      Result := Cpu_Reset_Counter.Count;
      Set_Component_Data_Region (Old_Component_Region);
      return Result;
   end Get;

end Reset_Counter;
